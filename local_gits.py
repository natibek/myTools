#!/usr/bin/env python3

import subprocess
import argparse
import os
from pretty_print import *

class readable_dir(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        prospective_dir=values
        if not os.path.isdir(prospective_dir) or not os.path.isdir(os.path.expanduser(prospective_dir)):
            raise argparse.ArgumentTypeError("readable_dir:{0} is not a valid path".format(prospective_dir))
        if os.access(prospective_dir, os.R_OK):
            setattr(namespace,self.dest,prospective_dir)
        else:
            raise argparse.ArgumentTypeError("readable_dir:{0} is not a readable dir".format(prospective_dir))

def check_git_status(git_dir, git_name, verbose, all):
    files = subprocess.check_output(
        ["git", "status", "--porcelain"], text=True, cwd=git_dir,
    ).split("\n")

    files = [file.strip() for file in files if file]
    
    if len(files) == 0:
        if all: print(success(git_name)) 
        return 0

    print(failure(git_name + " -> "), end="")

    modified_count = sum(1 for file in files if file[0] == "M") 
    untracked_count = sum(1 for file in files if file[0] == "?")

    if modified_count > 0:
        print(f"{failure('M')}odified: {failure(str(modified_count))}", end=" ") 
    
    if untracked_count > 0:
        print(f"{failure('U')}ntracked: {failure(str(untracked_count))}", end=" ") 
    print()

    if verbose:
        for file in files:
            print("  -", file)
    return 1

def get_git_dirs(home_dir):
    home_dir = os.path.expanduser(home_dir)
    git_dirs = subprocess.check_output(
        ["find", ".", "-name", ".git"], text=True, cwd=home_dir,
    ).split("\n")
    git_dirs = [os.path.abspath(os.path.dirname(home_dir + git_dir[1:])) for git_dir in git_dirs if git_dir]
    git_names = [os.path.basename(git_dir) for git_dir in git_dirs if git_dir]
    return list(zip(git_names, git_dirs))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--verbose", "-v", 
                        action="store_true", 
                        default=False, 
                        help="Whether the unpushed files should be shown."
                    )
    parser.add_argument("--exclude", "-x", 
                        type=str, 
                        nargs='*', 
                        help="The names of the github repos you don't want to check."
                    )
    parser.add_argument("--root", "-r", 
                        action=readable_dir, 
                        default=os.path.expanduser("~"), 
                        help="The root dir from which github repos should be searched for. ~ by default."
                    )
    parser.add_argument("--all", "-a",
                        action="store_true",
                        default=False,
                        help="Whether to show all the github repos. Default shows ones with unpushed changes."     
                    )

    args = parser.parse_args()

    exclude = [] if args.exclude is None else args.exclude

    gits = get_git_dirs(args.root)
    if len(gits) == 0:
        print("No local github repos found")
        return 0

    gits.sort(key=lambda x: x[0])

    exit_code = 0
    for git_name, git_dir in gits:
        if git_name not in exclude:
            exit_code |= check_git_status(git_dir, git_name, args.verbose, args.all)

    if exit_code == 9:
        print(success("All repos are pushed."))
    else:
        print()
    return exit_code 

if __name__ == "__main__":
    exit(main())