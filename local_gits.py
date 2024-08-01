#!/usr/bin/env python3

import argparse
import os
import subprocess

from pretty_print import *


class readable_dir(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        prospective_dir = values
        if not os.path.isdir(prospective_dir) or not os.path.isdir(
            os.path.expanduser(prospective_dir)
        ):
            raise argparse.ArgumentTypeError(
                "readable_dir:{0} is not a valid path".format(prospective_dir)
            )
        if os.access(prospective_dir, os.R_OK):
            setattr(namespace, self.dest, prospective_dir)
        else:
            raise argparse.ArgumentTypeError(
                "readable_dir:{0} is not a readable dir".format(prospective_dir)
            )


def commits_behind(git_dir: str, cur_branch: str) -> int:
    """Check how many commits you are behind."""

    subprocess.call("git fetch origin".split(" "), cwd=git_dir)
    commits_count = subprocess.check_output(
        f"git rev-list --left-right --count {cur_branch}...origin/{cur_branch}".split(
            " "
        ),
        text=True,
        cwd=git_dir,
    )[:-1].split("\t")
    return int(commits_count[1])


def git_unpushed_files(git_dir: str) -> list[str]:
    files = subprocess.check_output(
        ["git", "status", "--porcelain"],
        text=True,
        cwd=git_dir,
    ).split("\n")

    return [file.strip() for file in files if file]


def check_git_status(git_dir, git_name, verbose, all, untracked, modified, show_behind):

    files = git_unpushed_files(git_dir)

    cur_branch = subprocess.check_output(
        ["git", "branch", "--show-current"],
        text=True,
        cwd=git_dir,
    )[:-1]

    num_behind = commits_behind(git_dir, cur_branch) if show_behind else 0

    home_path = os.path.expanduser("~")
    file_display_text = failure(f"{git_name}") + f"<{cur_branch}>" + failure("-> ")

    if len(files) == 0 and num_behind == 0:
        if all:
            print(
                f"{git_dir.replace(home_path, '~')}: {success(git_name)}<{cur_branch}>"
            )
        return 0

    modified_count = sum(1 for file in files if file.startswith("M"))
    untracked_count = sum(1 for file in files if file.startswith("?"))

    if (
        (modified_count and modified)
        or (untracked_count and untracked)
        or num_behind > 0
    ):
        file_display_text = failure(f"{git_name}") + f"<{cur_branch}>" + failure("-> ")
        print_text = f"{git_dir.replace(home_path, '~')}: {file_display_text}"
    else:
        return 0

    if modified_count > 0 and modified:
        print_text += f"{failure('M')}odified:{failure(str(modified_count))} "
    if untracked_count > 0 and untracked:
        print_text += f"{failure('U')}ntracked:{failure(str(untracked_count))} "
    if num_behind > 0:
        print_text += f"{failure('B')}ehind:{failure(str(num_behind))}"

    print(print_text)

    if verbose:
        for file in files:
            if modified and file.startswith("M"):
                print("  -", file)
            if untracked and file.startswith("?"):
                print("  -", file)
    return 1


def get_git_dirs(home_dir):
    home_dir = os.path.expanduser(home_dir)
    git_dirs = subprocess.check_output(
        ["find", ".", "-name", ".git"],
        text=True,
        cwd=home_dir,
    ).split("\n")
    git_dirs = [
        os.path.abspath(os.path.dirname(home_dir + git_dir[1:]))
        for git_dir in git_dirs
        if git_dir
    ]
    git_dirs = [git_dir for git_dir in git_dirs if "local/share" not in git_dir]
    git_names = [os.path.basename(git_dir) for git_dir in git_dirs if git_dir]
    return list(zip(git_names, git_dirs))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        default=False,
        help="Whether the unpushed files should be shown.",
    )
    parser.add_argument(
        "--exclude",
        "-x",
        type=str,
        nargs="*",
        help="The names of the github repos you don't want to check.",
    )
    parser.add_argument(
        "--root",
        "-r",
        action=readable_dir,
        default=os.path.expanduser("~"),
        help="The root dir from which github repos should be searched for. ~ by default.",
    )
    parser.add_argument(
        "--all",
        "-a",
        action="store_true",
        default=False,
        help="Whether to show all the github repos. Default shows ones with unpushed changes.",
    )
    parser.add_argument(
        "--show-behind",
        action="store_true",
        default=False,
        help="Whether to also show how many commits a local repo is behind the origin.",
    )

    behind_type = parser.add_mutually_exclusive_group()
    behind_type.add_argument(
        "--modified",
        action="store_true",
        default=False,
        help="Whether to only check for modified files.",
    )
    behind_type.add_argument(
        "--untracked",
        action="store_true",
        default=False,
        help="Whether to only check for untracked files.",
    )

    args = parser.parse_args()

    untracked = (not args.modified and not args.untracked) or args.untracked
    modified = (not args.untracked and not args.modified) or args.modified
    exclude = [] if args.exclude is None else args.exclude

    gits = get_git_dirs(args.root)
    if len(gits) == 0:
        print("No local github repos found")
        return 0

    gits.sort(key=lambda x: x[0])

    exit_code = 0
    for git_name, git_dir in gits:
        if git_name not in exclude:
            exit_code |= check_git_status(
                git_dir,
                git_name,
                args.verbose,
                args.all,
                untracked,
                modified,
                args.show_behind,
            )

    if exit_code == 9:
        print(success("All repos are pushed."))
    else:
        print()
    return exit_code


if __name__ == "__main__":
    exit(main())
