# -*- encoding: utf-8 -*-

"""
Python (`matplotlib`, `seaborn`, etc.) Functions to Plot Trend Lines

Trend lines and charts are great ways to depict information over a
period of time, and related functions are grouped here.

@author:  Debmalya Pramanik
@copywright: pOrgz <https://github.com/pOrgz-dev>
"""

import numpy as np
import seaborn as sns
import matplotlib as mpl
import matplotlib.pyplot as plt

from typing import Iterable


def pn_bar_chart(p : Iterable, n : Iterable, x : Iterable, **kwargs):
    """
    Plot a Positive-Negative Bar Chart

    A bar chart that displays the positive and negative values for
    the same interval/category can be easily interpreted by dividing
    a bar chart into two parts on the axis.

    :type  p, n: array-like
    :param p, n: An iterable of positive and negative values
                 respectively, for every point in x-axis. All the
                 values in `p` is converted as $p_i >= 0` while for
                 `n` the formula for conversion is `np.abs(n) * (-1)`

    :type  x: array-like
    :param x: X values, which can either be time, or category or any
              value to be displayed in the x-axis of the plot.

    Keyword Arguments
    -----------------
    The function will gradually accept all keyword arguments supported
    by the `matplotlib` functions. However, currently the following
    keywords are defined:

        * *bar_width* (`int`): Populates the value of `width` param
          in the `plt.bar` function. Defaults to 1.

        * *p_bar_color*, *n_bar_color* (`str`): Hexadecimal or any
          other supported color formats for positive and negative
          bar chart. Defaults to `#419E55` for positive bar and
          `#9E4541` for negative bar.

        * *diff_plot* (`bool`): Plot the difference line along with
          the bar plots. The line plot in the `pm_bar_chart` will
          provide a trend over the x-axis which is useful when the
          x-values are time based. Defaults to False.

        * *title*, *xlabel*, *ylabel* (`str`): Use these keyword
          arguments to set `title`, `xlabel` and `ylabel` for the
          plot respectively.
    """

    fig, axs = plt.subplots(1, 1) # define figure object

    # get keyword arguments for the bar plot
    _bar_width = kwargs.get("bar_width", 1)
    _p_bar_color = kwargs.get("p_bar_color", "#419E55")
    _n_bar_color = kwargs.get("p_bar_color", "#9E4541")

    axs.bar(x, p, width = _bar_width, color = _p_bar_color)
    axs.bar(x, n, width = _bar_width, color = _n_bar_color)

    if kwargs.get("diff_plot", False):
        p, n = map(np.array, [p, n])
        axs.plot(x, (p - n), "k--", linewidth = 2)

    axs.tick_params(axis = "x", rotation = 90)
    axs.yaxis.set_major_formatter(mpl.ticker.StrMethodFormatter("{x:,.2f}"))

    # other figure parameters are defined

    axs.set_title(kwargs.get("title", None))
    axs.set_xlabel(kwargs.get("xlabel", None))
    axs.set_ylabel(kwargs.get("ylabel", None))
    fig.tight_layout()

    return fig
