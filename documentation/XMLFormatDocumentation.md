# IC XML Format documentation

In this file I will describe XML schema for Interactive Control. In shema I'll be using this symbols with this meaning:

* `( x | y )` - this means, that script using x OR y - not both at same time
* `[xyz=""]` - means that attribute is not required and default value is no set
* `[xyz="abc"]` - optional attribute with default value
* `[xyz="" abc="xyz"]` - list of optional attributes - if you fill one you must fill other
* `xyz=""//type` - means that attribute has type `type`
* Also whole tag can be optional
* Everything outside of [] breackets is required and without propper filling script will not work!

```xml
<!-- XML schema documentation -->
<fanSound>
	[<indicator 
		( animation=""//string | clipRoot=""//i3d_node clip=""//string )
		[index=""//i3d_node]
	/>]
	<sound [linkNode=""//i3d_node] [startOffset="0"//int]
		[randomMinRange=""//int randomMaxRange=""//int]>
		<sound />//SoundUtilNode
	</sound>
</fanSound>
```

## Setting up sounds

If you want to use this script, you need to set sound via node `vehicle.fanSound.sound.sound`. This node is loaded from SoundUtil. Also you can define start offset with which will be animation played. Offset is in **miliseconds**.

### Repetetive fan sound

You can set up `randomMinRange` and `randomMaxRange`. After fan sound turn off, script will generate random number in miliseconds between `randomMinRange` and `randomMaxRange` and after this random ammount of time it will play sound again. If you don't set this range, sound will be played only once.

## Setting up indicator

As you can see from format documentation you can set indicator for fan sound (if sound is on/off). Indicator can be simple object that will be toggled by visibility and/or animation. Animation can be from vehicle's XML file or from I3D. You can't have more than one animation as indicator.
