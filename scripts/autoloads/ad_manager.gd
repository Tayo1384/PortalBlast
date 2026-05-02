extends Node

signal banner_shown
signal interstitial_shown
signal rewarded_completed(success: bool)

const BANNER_ID := "ca-app-pub-2893772413483926/2797321829"
const INTERSTITIAL_ID := "ca-app-pub-2893772413483926/7199601261"
const REWARDED_ID := "ca-app-pub-2893772413483926/4977686047"

var _initialized: bool = false
var _banner: AdView = null
var _interstitial: InterstitialAd = null
var _rewarded: RewardedAd = null
var interstitial_counter: int = 0
const INTERSTITIAL_FREQUENCY: int = 3


func _ready() -> void:
	if GameManager.ads_consent == 1:
		_initialize()


func enable_ads() -> void:
	if not _initialized:
		_initialize()


func _initialize() -> void:
	var listener := OnInitializationCompleteListener.new()
	listener.on_initialization_complete = _on_init_complete
	MobileAds.initialize(listener)


func _on_init_complete(_status: InitializationStatus) -> void:
	_initialized = true
	_load_interstitial()
	_load_rewarded()


func show_banner() -> void:
	if _banner != null:
		_banner.show()
		banner_shown.emit()
		return

	_banner = AdView.new(BANNER_ID, AdSize.BANNER, AdPosition.Values.BOTTOM)
	_banner.ad_listener.on_ad_loaded = func():
		_banner.show()
		banner_shown.emit()
	_banner.ad_listener.on_ad_failed_to_load = func(_err: LoadAdError):
		_banner = null
	_banner.load_ad(AdRequest.new())


func hide_banner() -> void:
	if _banner:
		_banner.hide()


func show_interstitial_smart() -> bool:
	interstitial_counter += 1
	if interstitial_counter % INTERSTITIAL_FREQUENCY != 0:
		return false
	if _interstitial:
		_interstitial.show()
		interstitial_shown.emit()
		return true
	_load_interstitial()
	return false


func show_rewarded() -> void:
	if _rewarded:
		var reward_listener := OnUserEarnedRewardListener.new()
		reward_listener.on_user_earned_reward = func(_item: RewardedItem):
			rewarded_completed.emit(true)
		_rewarded.full_screen_content_callback.on_ad_dismissed_full_screen_content = func():
			_rewarded = null
			_load_rewarded()
		_rewarded.full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(_err: AdError):
			_rewarded = null
			_load_rewarded()
			rewarded_completed.emit(false)
		_rewarded.show(reward_listener)
	else:
		_load_rewarded()
		rewarded_completed.emit(false)


func _load_interstitial() -> void:
	var loader := InterstitialAdLoader.new()
	var callback := InterstitialAdLoadCallback.new()
	callback.on_ad_loaded = func(ad: InterstitialAd):
		_interstitial = ad
		_interstitial.full_screen_content_callback.on_ad_dismissed_full_screen_content = func():
			_interstitial = null
			_load_interstitial()
	callback.on_ad_failed_to_load = func(_err: LoadAdError):
		_interstitial = null
	loader.load(INTERSTITIAL_ID, AdRequest.new(), callback)


func _load_rewarded() -> void:
	var loader := RewardedAdLoader.new()
	var callback := RewardedAdLoadCallback.new()
	callback.on_ad_loaded = func(ad: RewardedAd):
		_rewarded = ad
	callback.on_ad_failed_to_load = func(_err: LoadAdError):
		_rewarded = null
	loader.load(REWARDED_ID, AdRequest.new(), callback)
