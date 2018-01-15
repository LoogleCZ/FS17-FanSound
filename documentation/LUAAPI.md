# Lua API for FanSound

Here you can find methods and variables used by FanSound script.

## Namespace

First of all please note that I use namespaces in my scripts to avoid variable names collision. In his case, namespace is `LFS`. So if you want to access some variable in my script, you probably must use something like `self.LFS.__variable_name__`.

## Used custom methods and functions

Please note in this list is only my non standart methods and functions - not standart game functions and methods.

* toggleSound
  * Definition:
    ```lua
      function FanSound:toggleSound(isOn, noEventSend)
      end;
    ```
  * Defined as: function, not method. So if you call this function you may use something like this:
    ```lua
      FanSound.toggleSound(self, ..., ...);
    ```
  * Parameters:
    1) `isOn` - define if sound will be played or muted. If omitted (or `nil`) default value of is set by variable `soundEnabled`
    2) `noEventSend` - determine if function will send event. If this parameter is `false` or `nil` event is send. Otherwise not.

## Variables

All variables have namespace prefix (`LFS`). So `sound` -> `self.LFS.sound`

* sound - SoundUtil node
* startOffset - int
* startSoundTime - int counter
* status - int
* minRandomTime - int
* maxRandomTime - int
* soundEnabled - bool

* indicator.object - object
* indicator.animation - nil/string
* indicator.animationI3D nil/animClipID
