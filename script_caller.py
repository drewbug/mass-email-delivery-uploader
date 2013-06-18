import imp
import sys
import os

#hardcoded settings
path_to_mass_emailer = "/Users/paul/mass-email-delivery-code/"
path_to_working_files = "/tmp/"
path_to_message_file = path_to_mass_emailer + "noCispaMessage.txt"
dry_run = True

#begin script
os.chdir(path_to_mass_emailer)
sys.path.append(path_to_mass_emailer)

senate_emailer = imp.load_source("EmailSenateFromCSV-FFTF", path_to_mass_emailer + "EmailSenateFromCSV-FFTF.py")
house_emailer = imp.load_source("EmailHouseFromCSV-FFTF", path_to_mass_emailer + "EmailHouseFromCSV-FFTF.py")

if __name__ == "__main__":
    csvfile = path_to_working_files + sys.argv[1]
    statfile = path_to_working_files + sys.argv[2]
    #do these sequentially because this file should already have been launched in parallel with other instances
    senate_emailer.csv_Send_To_Senate(csvfile, path_to_message_file, statfile, dryrun = dry_run)
    house_emailer.csv_Send_To_House(csvfile, path_to_message_file, statfile, dryrun = dry_run)
