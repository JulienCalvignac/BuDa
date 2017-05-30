import subprocess
import shlex


def define_parser():
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--sha",
                        dest="sha",
                        type=str,
                        help="sha",
                        required=True)
    parser.add_argument("-n", "--no-cache",
                        dest="no_cache",
                        action="store_true",
                        help="build without cache",
                        default=False)
    return parser

if __name__ == "__main__":
    parser = define_parser()
    arguments = parser.parse_args()

    image = "supervision{}".format(arguments.sha)

    no_cache_option = "--no-cache " if arguments.no_cache else ""

    subprocess.call(shlex.split("docker build -t {} -f Dockerfile {}..".format(image, no_cache_option)))
