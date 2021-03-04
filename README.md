# DOLORES
Apple //e Double LORES library

Purpose: DOLORES is an extension containing functions that enable
drawing on the Double LORES screen of an Apple //e enhanced or better.
This library should be included in any source code project in order to
easily access the single functions by direct subroutine calls after
setting the required variables.

NOTE: DOLORES must be assembled in the memory range from $6000-$8FFF
in order to work correctly since the code is copyied also to AUX mem to be
run there for certain functions!

Please note that DOLORES spoils parts of the zero page variables
which may leave your Apple in an undefined state. In order to prevent 
this you should save a copy of the zero page before calling DOLORES
functions!

More technical information can be found here:
http://golombeck.eu/index.php?id=48&L=1
