# Minimal instalation of IC

This tutorial will explain, how to integrate FanSound into your mod.

## Step 1

Place `FanSound.lua` from `release` somewhere in you mod's directory. Idealy in folder named `scripts` etc...

## Step 2

Register specialization in `modDesc.xml`.

You will need to tell game that this script is part of your mod. Here is an example:

```xml
<modDesc descVersion="37">
	<!-- rest of your modDesc here -->
	<specializations>
		<!-- rest of the specializations -->
		<specialization name="FanSound" className="FanSound" filename="__path_to_script__/FanSound.lua"/>
	</specializations>
</modDesc>
```

## Step 3

Now you need to add FanSound specialization into your vehicle type. This is done also in `modDesc.xml` in `<vehicleTypes>` section. Here is an example:

```xml
<modDesc descVersion="37">
	<!-- rest of your modDesc here -->
	<vehicleTypes>
		<!-- maybe other vehicleTypes -->
		<type name="yourVehicleType" className="Vehicle" filename="$dataS/scripts/vehicles/Vehicle.lua">
			<!-- rest of vehicle specializations here -->
			<specialization name="FanSound"/>
		</type>
	</vehicleTypes>
</modDesc>
```

By now you have done minimal modDesc instalation, but also some vehicle xml editing is needed. So follow the Step 4

## Step 4

Open you mod xml file, and scroll at the and of file. Before `</vehicle>` closing tag insert `fanSound` node like in example:

```xml
<vehicle type="yourVehicleType">
	<!-- rest of vehicle xml file here -->
	<fanSound>
		<!-- for full demo see xml format documentation -->
	</fanSound>
</vehicle>
```

Complete list of attributes and nodes can be found with explanation in [XML format documentation with explanation](./XMLFormatDocumentation.md).
