# -*- encoding: utf-8 -*-

"""
Extends the ENUM Class to Provide Additional Functions

ENUM class is great for setting unique values, and can be used as an
data type in any type of relational databases. Here, we extend the
class in python to provide additional functionalities.
"""

import enum

class ExtendedEnum(enum.Enum):

    @classmethod
    def names(cls):
        # return all names for an enum class
        return list(map(lambda c : c.name, cls))


    @classmethod
    def values(cls):
        # return all values for an enum class
        return list(map(lambda c : c.value, cls))


    @classmethod
    def dict(cls):
        # return name, value in a dictionary format
        return {c.name : c.value for c in cls}
