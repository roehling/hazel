Introduction
============

Hazel's design follows the concepts from the Gist `Effective Modern CMake`_.
Even if you do not read the whole document, there is one mantra that drives
pretty much all design decisions in Hazel: Think in terms of targets and
properties.

You may be familiar with GNU Make targets, which are basically recipes on how
to create files. CMake targets are subtly different: you do not tell CMake
`how` to create a target, but `what` the target should be, and it will figure
out the rest on its own. This may seem like pointless semantics to you, but it
makes all the difference. Far too many developers treat CMake like a fancy GNU
Make and tell it exactly how to do its job. They manually add compiler flags
and link dependencies, and when things break with a different compiler or
platform, they add complex detection code. They add code to deal with the
dependencies of their dependencies. After a while, when their CMake script has
accumulated a few hundred lines of cryptic variable assignments and conditional
statements, they come to the conclusion that CMake is a bad tool.

Did you know that you don't have to add the ``-fPIC`` flag to build position
independent code? Just tell CMake you want it with the target property
``POSITION_INDEPENDENT_CODE ON``. CMake will add ``-fPIC`` for you, or whatever
option your particular compiler needs.

Or did you know that you don't have to add the ``-std=c++11`` flag to ensure
the compiler understands C++11? Just tell CMake you want it with the target
compile feature ``cxx_std_11``. CMake will add ``-std=c++11`` or
``-std=gnu++11`` for you, but only if it is needed. No more accidental
downgrading from C++14.

This is a recurring pattern with CMake. The CMake developers are actually very
smart people who test their tool on a variety of platforms and compilers. You
are very unlikely to outsmart them with your ad-hoc CMake code, so why waste
the time?

Treat CMake targets like objects in C++. They have a type (executable,
library), some member variables (properties), and even something like member
functions (all functions with ``target_`` prefix). Just like you avoid global
variables in your C++ code, avoid setting global variables. It is a common
CMake anti-pattern to treat a CMake target ``foo`` like a dumb alias for
``-lfoo``, so you link against the library, but you also need to manually set
the include path and maybe some macro definitions, which are communicated
through global variables like ``foo_INCLUDE_DIRS``. But why should `I` have to
remember to set these properties when I use `your` library? Just tell CMake
which include paths and which macro definitions are needed when others link
against your target, and CMake will add everything automatically [#f1]_ .

The CMake developers have been extraordinarily careful to remain compatible
with older versions. Unfortunately, this means that many deprecated features
and obsolete design patterns are still in use today and even actively taught to
new developers, which is in no small part responsible for the prejudice that
CMake build scripts are an unmaintainable mess.

.. _Effective Modern CMake: https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1

.. [#f1]

    Since the library author is the one who has to tell CMake, you will
    inevitably run into third-party libraries whose authors do not know
    how to CMake. There are ways to deal with this using interface libraries
    though; it is how Hazel can provide you with nice targets such as
    ``catkin::package-name`` even though catkin itself does not.
