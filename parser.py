from argparse import ArgumentParser
import pandas


class Parser:

    def __init__(self, timestamp, output_filename, input_filename):
        self.energy, self.power, self.time = None, None, None
        self.import_data(input_filename)
        self.export_data(timestamp, output_filename)

    def export_data(self, timestamp, filename):
        """Export this to a CSV."""
        df = pandas.DataFrame(columns=["timestamp", "total_energy_consumption", "average_power", "time_elapsed"])
        data = {
            "timestamp": timestamp,
            "total_energy_consumption": self.energy,
            "average_power": self.power,
            "time_elapsed": self.time
        }
        df = df.append(data, ignore_index=True)
        df.to_csv(f"{filename}.csv")

    def import_data(self, filename):
        pass


class PerfParser(Parser):

    def __init__(self, timestamp, output_filename, input_filename):
        super().__init__(timestamp, output_filename, input_filename)

    def import_data(self, filename):
        """Imports data from a txt file outputted by Perf."""
        with open(filename + ".txt", "r") as f:
            lines = f.readlines()
            self.energy = float(lines[5].strip(" ").split(" ")[0])
            self.time = float(lines[7].strip(" ").split(" ")[0])
            self.power = self.energy / self.time


class PowerLogParser(Parser):

    def __init__(self, timestamp, output_filename, input_filename):
        super().__init__(timestamp, output_filename, input_filename)

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
    parser.add_argument('-t', '--timestamp', required=True, type=str, help="Timestamp of when measurement started.")
    parser.add_argument('-o-', '--output', required=True, type=str, help="Name of CSV file for output.")
    parser.add_argument('-i', '--input', required=False, type=str, help="File with raw data.")
    args = parser.parse_args()

    if args.input is None:
        args.input = "temp"

    if args.measurement == "powerlog":
        PowerLogParser(args.timestamp, args.output, args.input)
    elif args.measurement == "perf":
        PerfParser(args.timestamp, args.output, args.input)
