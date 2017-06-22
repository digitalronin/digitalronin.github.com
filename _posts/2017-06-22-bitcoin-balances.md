---
layout: post
title: "Checking Bitcoin balances"
description: "Find the current balance of all bitcoin addresses to/from which you've sent any bitcoin"
category:
tags: [bitcoin,jq,bash]
---

[Stellar][stellar] are [giving away][giveaway] some of their cryptocurrency, Lumens, to anyone who owns [Bitcoin][bitcoin].

To get the Stellar, you need to prove you own the Bitcoin by providing your Bitcoin address(es) and then signing a message to prove you control that address.

I've used a lot of addresses, over time, so figuring out which of these addresses I need to provide can be time-consuming.

[Bash][bash] to the rescue;

{% gist digitalronin/29a6d1386e6be145437b5f39f929429d %}

To use this, I first export a CSV of all the bitcoin transactions I've ever done. Then I run the script like this;

```bash
./balances.sh tx.csv
```

...where `tx.csv` is the filename of my exported transaction data.

The script works through all the addresses I've ever interacted with, and looks up the details for that address on [blockchain.info][blockchain.info]

NB: I included both sent and received transactions, because sometimes I've sent bitcoin to another wallet address, so it's useful to find out the balance of addresses I've sent bitcoin to as well as bitcoin I've received. Be aware that if you've sent BTC to someone else, this script will show you **their** current bitcoin balance, if they haven't sent the funds on to another address.

[stellar]: https://www.stellar.org/
[giveaway]: https://www.stellar.org/blog/bitcoin-claim-lumens-2/
[bitcoin]: https://bitcoin.org
[bash]: https://en.wikipedia.org/wiki/Bash_(Unix_shell)
[blockchain.info]: https://blockchain.info

