#!/usr/bin/env python3

import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

import os


VERBOSE = False
IMAGE_SIZE_PX = (1920, 1080)
IMAGE_DPI = 100


def main(n_ghostspawns):
    """Entry point."""
    FOLDER = os.path.join(os.path.dirname(os.path.realpath(__file__)), "dataset")
    assert os.path.isdir(FOLDER), FOLDER

    PATH_DATA = os.path.join(
        FOLDER,
        f"test_probabilities_streak_{n_ghostspawns}ghost.txt",
    )

    DATA = get_datapoints(PATH_DATA, VERBOSE)

    DATA_list = [k for k, v in DATA.items() for _ in range(v)]

    ax = plt.subplot(111)
    # ax.set_ylim(0, 30000)
    ax.set_ylabel("Number of n-streak occurrences per 100k iterations", color="blue")
    ax.set_xlabel(
        "Number of consecutive favourable ghost spawn locations per team (n)",
        color="black",
    )
    ax.tick_params(axis="y", labelcolor="blue")
    for axis in [ax.xaxis, ax.yaxis]:
        axis.set_major_locator(ticker.MaxNLocator(integer=True))
    ax.plot(DATA.keys(), DATA.values(), color="blue")
    for k, v in DATA.items():
        y = 100.0 * v / sum([k2 * v2 for k2, v2 in DATA.items()])
        ax.annotate(
            f"n={k} ({y:.2f} %, {v}/100k)",
            (k, v - 0.1),
            color="black" if v > 0 else "grey",
            rotation=25,
        )

    ax2 = ax.twinx()
    ax2.yaxis.set_label_position("right")
    ax2.yaxis.tick_right()
    ax2.set_ylabel("Frequency %", color="black")
    ax2.tick_params(labelcolor="black")
    ax2.get_yaxis().set_ticks([])
    # ax2.set_ylim(0, 30)
    ax2.plot(
        DATA.keys(),
        [
            100.0 * (v / sum([k2 * v2 for k2, v2 in DATA.items()]))
            for k, v in DATA.items()
        ],
        color="black",
        linestyle="dashed",
        alpha=0,
    )

    ax3 = ax2.twinx()
    # ax3.get_yaxis().set_ticks([])
    # ax3.get_xaxis().set_ticks([])
    ax3.grid(True)
    ax3.plot(
        DATA.keys(),
        [100.0 * pow(0.5, n) for n in range(1, max(DATA.keys()) + 1)],
        color="red",
        linestyle="dashed",
    )
    ax3.annotate("Expected probability (50%^n)", (10 / 2, -1.0), color="red")

    plt.title(
        "Ghost spawn location distribution of 100 000 simulated back-to-back rounds, using "
        f"{n_ghostspawns} total ghost spawn locations"
    )

    fig = plt.gcf()
    fig.set_size_inches((dimension / IMAGE_DPI for dimension in IMAGE_SIZE_PX))

    img_path = os.path.join(
        os.path.dirname(os.path.realpath(__file__)),
        "images",
        f"ghostspawn_sim_{n_ghostspawns}_ghosts.png",
    )
    with open(img_path, mode="wb") as f_img:
        plt.savefig(f_img, dpi=IMAGE_DPI)
        print(f"Figure image saved to: {img_path}")
    if VERBOSE:
        plt.show()
    else:
        fig.clf()


def get_datapoints(path, verbose=False):
    """Read all the data points from the log file producer by the "test_bias" plugin."""
    assert os.path.isfile(path), path
    with open(path, mode="r", encoding="utf-8") as f:
        lines = f.readlines()

    vals = [x.strip() for x in lines]
    nums = []
    for val in vals:
        if val.isnumeric():
            nums.append(int(val))
    nums.sort()

    freq = {}
    # Pad out the statistics to include this many values.
    maximum = 16
    # Results should never exceed the max value
    assert nums[-1] <= maximum
    for num in range(1, maximum + 1):
        # If no results, add zero so we get graphs that are easily visually compared with each other
        if num not in nums:
            freq[num] = 0
    for num in nums:
        if num in freq:
            freq[num] += 1
        else:
            freq[num] = 1
    if verbose:
        print(freq)
    # Not really worth sorting since dict order is implementation detail, but meh
    return dict(sorted(freq.items()))


if __name__ == "__main__":
    nums_ghost_spawns = (16,)  # (2, 4, 6, 8, 16)
    for n in nums_ghost_spawns:
        main(n)
