class_name MarketAgent


var money : float
var commodity := 0.0

var _trade_interval : float
var _market : Market
var _buy : float
var _sell : float
var _volume : float

var _timer := 0.0


func _init(
	market : Market,
	money : float,
	trade_interval : float,
	buy : float,
	sell : float,
	volume : float
) -> void:
	
	_market = market
	self.money = money
	_trade_interval = trade_interval
	_buy = buy
	_sell = sell
	_volume = volume


func update(delta : float):
	_timer += delta
	
	if _timer > _trade_interval:
		_timer -= _trade_interval
		
		if _market.price < _buy:
			buy()
		elif _market.price > _sell:
			sell()


func buy():
	pass


func sell():
	pass
