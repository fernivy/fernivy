from argparse import ArgumentParser
import csv


class Processor:

    def __init__(self, measurement, runs, input_filename, output_filename):
        self.data = []
        self.measurement = measurement
        self.runs = runs

        self.import_data(input_filename)
        self.export_data(output_filename)

    def export_data(self, filename):
        columns = ["index", "timestamp", "total_energy_consumption", "average_power", "time_elapsed"]
        with open(filename, 'w') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=columns)
            writer.writeheader()
            for i, result in enumerate(self.data):
                writer.writerow(result.export_data(i))
            writer.writerow({})
            writer.writerow(self.get_avg())

    def get_avg(self):
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

    def import_data(self, filename):
        for i in range(self.runs):
            f = filename + str(i)
            if self.measurement == "powerlog":
                p = PowerLogResult(f)
            elif self.measurement == "perf":
                p = PerfResult(f)
            else:
                raise ValueError("Invalid measurement type.")
            self.data.append(p)


class Result:

    def __init__(self, input_filename):
        self.timestamp, self.energy, self.power, self.time = None, None, None, None
        self.import_data(input_filename)

    def export_data(self, index):
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

    def __init__(self, input_filename):
        super().__init__(input_filename)

    def import_data(self, filename):
        """Imports data from a txt file outputted by Perf."""
        with open(filename + ".txt", "r") as f:
            lines = f.readlines()
            # TueMar29160704CEST2022
            self.timestamp = " ".join(lines[0].split(" ")[3:]).strip()
            self.energy = float(lines[5].strip(" ").split(" ")[0])
            self.time = float(lines[7].strip(" ").split(" ")[0])
            self.power = self.energy / self.time


class PowerLogResult(Result):

    def __init__(self, input_filename):
        super().__init__(input_filename)

    def import_data(self, filename):
        """Imports data from a csv file outputted by PowerLog."""
        with open(filename + ".csv", "r") as file:
            lines = file.readlines()
            self.energy = float(lines[-11].split(" = ")[1][:-2])
            self.power = float(lines[-9].split(" = ")[1][:-2])
            self.time = float(lines[-14].split(" = ")[1][:-2])


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('-m', '--measurement', required=True, type=str, help="Measuring tool used.")
    parser.add_argument('-r', '--runs', required=True, type=int, help="Number of runs.")
    parser.add_argument('-o-', '--output', required=True, type=str, help="Name of CSV file for output.")
    parser.add_argument('-i', '--input', required=False, type=str, help="File with raw data.")
    args = parser.parse_args()

    if args.input is None:
        args.input = "temp"

    Processor(args.measurement, args.runs, args.input, args.output)
