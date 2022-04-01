from argparse import ArgumentParser
import csv


class FileList:
    """
    This class reads the names of all the result files from the name file.
    """

    def __init__(self, filename):
        self._files = [line.strip() for line in open(filename)]

    @property
    def files(self):
        return self._files

    @property
    def size(self):
        return len(self._files)


class Processor:
    """
    This class processes the data into the final output CSV.
    """

    def __init__(self, measurement, input_files, output_filename):
        """
        :param measurement: The tool that was used for measurement.
        :param input_files: The `FileList` class instance holding all the relevant file names.
        :param output_filename: The name of the target file.
        """
        self.data = []
        self.measurement = measurement
        self.runs = input_files.size

        self.import_data(input_files)
        self.export_data(output_filename)

    def import_data(self, files):
        """
        This method imports the data from all files containing the measurements from the tool.
        :param files: The `FileList` class instance holding all the relevant file names.
        """
        for i in range(self.runs):
            f = files.files[i] # find the correct file
            if self.measurement == "powerlog":
                p = PowerLogResult(f)
            elif self.measurement == "perf":
                p = PerfResult(f)
            else:
                raise ValueError("Invalid measurement type.")
            self.data.append(p)

    def export_data(self, filename):
        """
        This methods exports all the data to the target CSV.
        :param filename: The name of the target CSV.
        """
        columns = ["index", "timestamp", "total_energy_consumption", "average_power", "time_elapsed"]
        with open(filename, 'w') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=columns)
            writer.writeheader()
            for i, result in enumerate(self.data):
                writer.writerow(result.export_data(i))
            writer.writerow({})
            writer.writerow(self.get_avg())

    def get_avg(self):
        """
        This method calculates all the averages to append to the end of the target file.
        :return: A dictionary containing the column-average pairs.
        """
        energy = 0
        power = 0
        time = 0
        for result in self.data:
            energy += result.energy
            power  += result.power
            time   += result.time
        return {
            "index": "avg",
            "timestamp": "",
            "total_energy_consumption": energy / len(self.data),
            "average_power": power / len(self.data),
            "time_elapsed": time / len(self.data)
        }


class Result:
    """
    This (abstract) class represents the results from one measurement file.
    """

    def __init__(self, input_filename):
        self.timestamp, self.energy, self.power, self.time = None, None, None, None
        self.import_data(input_filename)

    def export_data(self, index):
        """
        This method exports the data of one measurement.
        :param index: The index of the measurement.
        :return: A dictionary containing the column-value pairs.
        """
        return {
            "index": index,
            "timestamp": self.timestamp,
            "total_energy_consumption": self.energy,
            "average_power": self.power,
            "time_elapsed": self.time
        }

    def import_data(self, filename):
        pass


class PerfResult(Result):
    """
    The concrete implementation of `Result` for Perf.
    """

    def __init__(self, input_filename):
        super().__init__(input_filename)

    def import_data(self, filename):
        """
        This method imports data from a txt file output by Perf.
        """
        with open(filename, "r") as f:
            lines = f.readlines()
            # TueMar29160704CEST2022
            self.timestamp = " ".join(lines[0].split(" ")[3:]).strip()
            self.energy = float(lines[5].strip(" ").split(" ")[0])
            self.time = float(lines[7].strip(" ").split(" ")[0])
            self.power = self.energy / self.time


class PowerLogResult(Result):
    """
    The concrete implementation of `Result` for PowerLog.
    """

    def __init__(self, input_filename):
        super().__init__(input_filename)

    def import_data(self, filename):
        """
        This method imports data from a txt file output by PowerLog.
        """
        with open(filename, "r") as file:
            lines = file.readlines()
            self.energy = float(lines[-11].split(" = ")[1][:-2])
            self.power = float(lines[-9].split(" = ")[1][:-2])
            self.time = float(lines[-14].split(" = ")[1][:-2])


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('-m', '--measurement', required=True, type=str, help="Measuring tool used.")
    parser.add_argument('-o-', '--output', required=True, type=str, help="Name of CSV file for output.")
    parser.add_argument('-i', '--input', required=True, type=str, help="File with filenames which contain raw data.")
    args = parser.parse_args()

    temp = FileList(args.input) # get the object holding the relevant filenames
    Processor(args.measurement, temp, args.output)
