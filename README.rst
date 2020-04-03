.. image:: screenshot.png

``paclabel`` is a tiny ``pacman`` wrapper.
It makes possible to attach custom text "labels" to packages.
The labels will be shown while querying the packages using ``-Q``
(unless options like ``-q`` or ``-k`` are passed, of course).

.. contents:: Navigation:
   :backlinks: none

============
Installation
============

Get it from AUR_.

=====
Usage
=====

Any valid invocations of ``pacman`` are also valid invocations of ``paclabel``
(if it isn't like this, it is considered a bug).
In fact, the author does ``alias pacman=paclabel``.

``paclabel`` also provides these tiny extensions to the CLI of ``pacman``:

* While installing a package you may specify a space-separated list of labels
  that will be attached to the package by following the package name with a semicolon.
  Here is an example:
  
  .. code-block:: bash
     
     paclabel -S pulseaudio:bloat gcc:"compiler The-Holy-C development"

  Label *bloat* will be attached to ``pulseaudio``.
  Labels *compliler*, *The-Holy-C* and *development* will be attached to ``gcc``.

* While querying packages the labels will be shown next to package names.

* A new operation ``-L`` is provided. The current interface is

  * ``paclabel -Ll`` to list all set labels.
  * ``paclabel -Ld pkg`` to delete all labels associated with *pkg*.
  * ``paclabel -Ls pkg:"labels"`` to overwrite the previous labels of *pkg*,
    if such exist, and attach *labels* to *pkg*.

  ``-l`` can be combined with ``-d`` and ``-s``.

=======
Storage
=======

Labels are stored in ``/etc/paclabel/labels``.
Manual editing of the file is perfectly fine.

=======
Caveats
=======

If ``paclabel`` encounters a long option, such as ``--query`` or ``--explicit``,
``paclabel`` gives up and just passes the arguments to ``pacman``. For example,

* ``paclabel -Qe`` shows the labels.
* ``paclabel -Q --explicit`` and ``paclabel --query -e`` don't.

==========
Motivation
==========

The author finds it useful to be able to attach
things like installation reason to a package.

.. LINKS
.. _AUR: https://aur.archlinux.org/packages/paclabel-git/
