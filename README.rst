InstantRst
===========

:version: 0.9.7

..

    So, You'll see.

    -- InstantRst


A vim plugin for preview rst document instantly.

.. figure:: https://github.com/Rykka/github_things/raw/master/image/rst_quick_start.gif 
    :align: center

    Screencast with riv.vim_

    Theme with rhythm.css_

----

This is an intro for vim usage.

To use the server, see instant-rst.py_.

Install
-------

1. Vim with Vundle or NeoBundle:

   ``NeoBundle 'Rykka/InstantRst'``

2. Python:

.. code:: sh

   # Got some issue on pypi
   # sudo pip install instant-rst
   sudo pip install https://github.com/Rykka/instant-rst.py/archive/master.zip

3. Curl:

.. code:: sh

   sudo apt-get install curl

Commands
--------

Inside a rst buffer.


:InstantRst[!]
    Preview current buffer.
    Add ``!`` to  preview **ALL** rst buffer.

:StopInstantRst[!]
    Stop Preview current buffer
    Add ``!`` to  stop preview **ALL** rst buffer.


Options
-------

g:instant_rst_slow
    Preview rst in fast or slow mode, default is ``0``.
    If your computer is a bit slow, set it to 1.

g:instant_rst_browser 
    Web browser for preview. default is ``''``.
    And then ``firefox`` will be used.

g:instant_rst_port
    The port of webserver, default is ``5676``.

    Then the server is at http://localhost:5676

g:instant_rst_forever 
    Always preview all rst buffer, default is ``0``.

g:instant_rst_bind_scroll
    Bind scroll with browser.

    When scrolling with Vim, The browser will scroll either.

    default is ``1``

TODO
----

1. rst's inline image file contained are not displayed.

Related
-------

This plugin is for Riv.vim_.

which is vim plugin for writing rst documents.

License
-------

MIT

.. sectnum::
.. _riv.vim: https://github.com/Rykka/riv.vim
.. _typo.css: https://github.com/sofish/Typo.css
.. _instant-rst.py: https://github.com/rykka/instant-rst.py
.. _rhythm.css: https://github.com/Rykka/rhythm.css
