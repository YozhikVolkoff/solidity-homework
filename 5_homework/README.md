В lottery.sol есть такая уязвимость:

```
function takeBet() haveMinValue public payable  {
        if (token.balanceOf(msg.sender) > 0 && msg.value == 0.42 * 1 ether) {
            msg.sender.transfer(this.balance);
            winners[msg.sender] = true;
            return;
        }
```

Как видно, достаточно сделать 2 шага: сначала завести ставку с минимальным количеством Эфира для участия в лотерее,
здесь это 0.1 eth, а затем завести ставку с 0.42 eth. При этом смартконтракт пошлет поставившему ставку все свои средства.

Хотелось бы только знать наперед, имеет ли это смысл. Может, там слишком мало средств даже на покрытие комиссии.