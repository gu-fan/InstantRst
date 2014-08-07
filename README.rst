InstantRst
===========

It's a webserver and vim plugin for you to preview rst instantly,

Kind of thing like instan-markdown-d_, 

But for reStructuredText and using python.

And it's using sofish's typo.css_ for better layout.

Install:
--------

1. Vundle `Rykka/InstantRst`
2. Python: `pip install flask flask-socketio docutils pygments`

Usage
-----

In a rst buffer:

Use ``:InstantRst`` to preview current buffer.

And you can use ``InstantRst!`` to preview all rst buffer.

Use ``:StopInstantRst`` to stop Preview current buffer

You should open a browser at http://localhost:5676

**Options:**

    `g:instant_rst_slow`: preview rst fast or slow, default is 0.
    `g:instant_rst_browser`: preview rst with browser. default is ''.


And you can start the server by your self. which is ``after/ftplugin/rst/instantRst.py``

with command ``python /path/to/instantRst.py``

TODO
----

1. rst's inline image file contained are not displayed.

Related
-------

You can use Riv.vim_ to write your rst documents.

.. _instan-markdown-d: https://github.com/suan/instant-markdown-d

.. _Riv.vim: https://github.com/Rykka/riv.vim

.. _typo.css: https://github.com/sofish/Typo.css
