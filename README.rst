InstantRst
===========

    So, You'll see.

    -- InstantRst


:version: 0.9

A vim plugin for you to preview rst instantly.

And a webserver contained in.

A screencast with Riv.vim_ and InstantRst_

.. image:: https://github.com/Rykka/riv.vim/raw/master/intro.gif

Like instant-markdown-d_, But for reStructuredText and using python.

The theme is http://rykka.github.io/rst-html-theme/

Install
-------

1. Using Vundle or NeoBundle
   ``Rykka/InstantRst``

2. Python:
   ``sudo pip install flask flask-socketio docutils pygments``

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
    `g:instant_rst_forever`: auto preview all rst buffer, default is 0.


And you can start the server by your self. which is ``after/ftplugin/rst/instantRst.py``

with command ``python /path/to/instantRst.py``

TODO
----

1. rst's inline image file contained are not displayed.

Related
-------

You can use Riv.vim_ to write your rst documents.

.. _instant-markdown-d: https://github.com/suan/instant-markdown-d

.. _Riv.vim: https://github.com/Rykka/riv.vim

.. _typo.css: https://github.com/sofish/Typo.css

