---
layout: post
title: "Keeping secrets with Vim encryption"
description: ""
category:
tags: [vim]
---

<center>
<p>
<img src="/images/encryption.jpg" width="300" height="200" />
</p>
</center>

The other day, I discovered that vim has an "encryption" mode. In this mode, your file is encrypted whenever it is written to disk, and decrypted whenever it's read back (this also applies to any temporary swap files).

I used to use the [gnupg plugin][gnupg-vim] for this, but it's pretty tedious to have to type a long passphrase every time you want to edit a file, and it's overkill for most things. The only scenario I really need to worry about is my laptop getting stolen[^1], which means an attacker is not going to be seriously interested in trying to decrypt my stuff.

To use encryption mode, just type ``:X<enter>`` from normal mode, when editing a document, and vim will prompt you for a password. Thereafter, you will need that same password every time you edit that file.

It's quick and easy, but there is one caveat - by default, the encryption that vim uses is very weak. Out of the box, it uses the same encryption as [PkZip][pkzip], which really doesn't cut it, even for casual secrets.

But, it's very easy to configure vim to use [Blowfish][blowfish] encryption, all you need to do is open up your ``.vimrc`` file and add this line;

    set cm=blowfish2

Any files you encrypt after this will be protected by the [Blowfish][blowfish] cipher, which is more than enough for casual use.

<hr />

[^1]: Yes, I use [full-disk encryption][filevault], but I believe in [defence in depth][defence-in-depth].
[gnupg-vim]: http://www.vim.org/scripts/script.php?script_id=3645
[blowfish]: https://en.wikipedia.org/wiki/Blowfish_(cipher)
[defence-in-depth]: https://en.wikipedia.org/wiki/Defence_in_depth
[filevault]: https://support.apple.com/en-us/HT204837
[pkzip]: https://en.wikipedia.org/wiki/PKZIP
