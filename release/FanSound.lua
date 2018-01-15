--
-- Fan sound specialization. Rewrite of JD7230RFAN specialization by Ago.
-- Original script author: Ago-Systemtech (https://www.fb.com/ago.systemtech - Modhoster Team)
-- Author of rewrite:      Martin Fabík (https://www.fb.com/LoogleCZ)
-- 
-- GitHub repository: https://github.com/LoogleCZ/FS17-FanSound
--
-- Free for non-comerecial usage!
--
-- version ID   - 1.0.0
-- version date - 2017-12-20 00:18
--
-- used namespace: LFS
--

FanSound = {};

function FanSound.prerequisitesPresent(specializations)
	return true;
end;

function FanSound:load(savegame)
	self.LFS = {};
	if self.isClient then
		local linkNode = getXMLString(self.xmlFile, "vehicle.fanSound.sound#linkNode");
		local linkObject = nil;
		if linkNode then
			linkObject = Utils.indexToObject(self.components, linkNode);
		end;
		
		self.LFS.sound          = SoundUtil.loadSample(self.xmlFile, {}, "vehicle.fanSound.sound.sound", nil, self.baseDirectory, linkObject);
		self.LFS.startOffset    = Utils.getNoNil(getXMLInt(self.xmlFile, "vehicle.fanSound.sound#startOffset"), 0);
		self.LFS.startSoundTime = 0;
		self.LFS.playTime       = self.LFS.sound.duration;
		self.LFS.status         = 0;
		self.LFS.minRandomTime  = getXMLInt(self.xmlFile, "vehicle.fanSound.sound#randomMinRange");
		self.LFS.maxRandomTime  = getXMLInt(self.xmlFile, "vehicle.fanSound.sound#randomMaxRange");
	
	
		self.LFS.indicator = {};
		self.LFS.indicator.looping = Utils.getNoNil(getXMLBool(self.xmlFile, "vehicle.fanSound.indicator#loopingAnimation"), false);
		self.LFS.indicator.animation = getXMLString(self.xmlFile, "vehicle.fanSound.indicator#animation");
		if self.LFS.indicator.animation == nil then
			self.LFS.indicator.animationI3D = nil;
			
			local clipParent = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.fanSound.indicator#clipRoot"));
			local animClip = nil;
			if clipParent ~= nil and clipParent ~= 0 then
				animClip = {};
				animClip.animCharSet = getAnimCharacterSet(clipParent);
				if animClip.animCharSet ~= 0 then
					local clip = getAnimClipIndex(animClip.animCharSet, getXMLString(self.xmlFile, "vehicle.fanSound.indicator#clip"));
					assignAnimTrackClip(animClip.animCharSet, 0, clip);
					setAnimTrackLoopState(animClip.animCharSet, 0, self.LFS.indicator.looping);
					animClip.animDuration = getAnimClipDuration(animClip.animCharSet, clip);
					setAnimTrackTime(animClip.animCharSet, 0, 0);
					setAnimTrackSpeedScale(animClip.animCharSet, 0, 1);
				end;
			end;
			
			if animClip ~= nil and animClip.animCharSet ~= nil and animClip.animCharSet ~= 0 then
				self.LFS.indicator.animationI3D = animClip;
			end;
		end;
		
		local node = getXMLString(self.xmlFile, "vehicle.fanSound.indicator#index");
		if node then
			self.LFS.indicator.object = Utils.indexToObject(self.components, node);
		end;
	end;
	self.LFS.soundEnabled = false;
end;

function FanSound:postLoad(savegame)
	if self.isClient and self.LFS.sound == nil then
		print("[ERROR]: You are using FanSound script, but you have not set sound file!");
	end;
	if self.LFS.indicator.animation and not SpecializationUtil.hasSpecialization(AnimatedVehicle, self.specializations) then
		print("[ERROR]: If you want to use XML animations is FanSound specialization you also need AnimatedVehicle specialization!");
		self.LFS.indicator.animation = nil;
	end;
end;

function FanSound:delete() 
	if self.isClient and self.LFS.sound ~= nil then
		SoundUtil.deleteSample(self.LFS.sound);
	end;
end;

function FanSound:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
     return BaseMission.VEHICLE_LOAD_OK;
end;

function FanSound:update(dt)
	if self.isClient then
		if not self.isMotorStarted and (self.LFS.status ~= 0 or self.LFS.startSoundTime ~= 0) then
			FanSound.toggleSound(self, false);
			self.LFS.startSoundTime = 0;
			self.LFS.status         = 0;
		end;
		if self.LFS.status == 0 then
			if self.isMotorStarted and not self.LFS.soundEnabled then
				self.LFS.startSoundTime = self.LFS.startSoundTime + dt;
			end;
			if self.LFS.startSoundTime > self.LFS.startOffset then
				FanSound.toggleSound(self, true);
				self.LFS.startSoundTime = 0;
				self.LFS.status         = 1;
			end;
		end;
		if self.isMotorStarted and self.LFS.soundEnabled and self.LFS.status == 1 then
			self.LFS.playTime = self.LFS.playTime - dt;
			if self.LFS.playTime <= 0 then
				FanSound.toggleSound(self, false);
				self.LFS.status = 2;
				if self.LFS.minRandomTime ~= nil and self.LFS.maxRandomTime ~= nil then
					self.LFS.startSoundTime = math.random(self.LFS.minRandomTime, self.LFS.maxRandomTime);
				end;
			end;
		end;
		if self.LFS.status == 2 and self.LFS.minRandomTime ~= nil and self.LFS.maxRandomTime ~= nil then
			self.LFS.startSoundTime = self.LFS.startSoundTime - dt;
			if self.LFS.startSoundTime <= 0 then
				FanSound.toggleSound(self, true);
				self.LFS.startSoundTime = 0;
				self.LFS.status         = 1;
			end;
		end;
	end;
end;

function FanSound:toggleSound(isOn, noEventSend)
	if isOn == nil then
		isOn = self.LFS.soundEnabled;
	end;
	if self.isClient then
		if isOn then
			self.LFS.playTime = self.LFS.sound.duration;
			if self.LFS.sound ~= nil and self.LFS.sound.sound3D ~= nil then
				SoundUtil.play3DSample(self.LFS.sound);
			else
				SoundUtil.playSample(self.LFS.sound, 1, 0, nil);
			end;
			if self.LFS.indicator.animation then
				self:playAnimation(self.LFS.indicator.animation, 1, Utils.clamp(self:getAnimationTime(self.LFS.indicator.animation), 0, 1), true);
			end;
			if self.LFS.indicator.animationI3D then
				if self.LFS.indicator.looping then
					enableAnimTrack(self.LFS.indicator.animationI3D.animCharSet, 0);
				else
					if getAnimTrackTime(self.LFS.indicator.animationI3D.animCharSet, 0) < 0.0 then
						setAnimTrackTime(self.LFS.indicator.animationI3D.animCharSet, 0, 0.0);
					end;
					setAnimTrackSpeedScale(self.LFS.indicator.animationI3D.animCharSet, 0, 1);
					enableAnimTrack(self.LFS.indicator.animationI3D.animCharSet, 0);
				end;
			end;
		else
			if self.LFS.sound ~= nil and self.LFS.sound.sound3D ~= nil then
				SoundUtil.stop3DSample(self.LFS.sound);
			else
				SoundUtil.stopSample(self.LFS.sound);
			end;
			if self.LFS.indicator.animation then
				if self.LFS.indicator.looping then
					self:stopAnimation(self.LFS.indicator.animation, true);
				else
					self:playAnimation(self.LFS.indicator.animation, -1, Utils.clamp(self:getAnimationTime(self.LFS.indicator.animation), 0, 1), true);
				end;
			end;
			if self.LFS.indicator.animationI3D then
				if self.LFS.indicator.looping then
					disableAnimTrack(self.LFS.indicator.animationI3D.animCharSet, 0);
				else
					if getAnimTrackTime(self.LFS.indicator.animationI3D.animCharSet, 0) > self.LFS.indicator.animationI3D.animDuration then
						setAnimTrackTime(self.LFS.indicator.animationI3D.animCharSet, 0, self.LFS.indicator.animationI3D.animDuration);
					end;
					setAnimTrackSpeedScale(self.LFS.indicator.animationI3D.animCharSet, 0, -1);
					enableAnimTrack(self.LFS.indicator.animationI3D.animCharSet, 0);
				end;
			end;
		end;
		if self.LFS.indicator.object then
			setVisibility(self.LFS.indicator.object, isOn);
		end;
	end;
	self.LFS.soundEnabled = isOn;
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(FanSoundEvent:new(self, isOn), nil, nil, self);
		else
			g_client:getServerConnection():sendEvent(FanSoundEvent:new(self, isOn));
		end;
	end;
end;

function FanSound:readStream(streamId, connection)
	self.LFS.soundEnabled = streamReadBool(streamId);
	FanSound.toggleSound(self);
end;

function FanSound:writeStream(streamId, connection)
	streamWriteBool(streamId, self.LFS.soundEnabled);
end;

--
-- Unused callbacks
--

function FanSound:mouseEvent(posX, posY, isDown, isUp, button) end;
function FanSound:keyEvent(unicode, sym, modifier, isDown) end;
function FanSound:updateTick(dt) end;
function FanSound:draw() end;
function FanSound:startMotor() end;
function FanSound:stopMotor() end;
function FanSound:onEnter() end;
function FanSound:onLeave() end;

--
-- Event class
--

FanSoundEvent = {};
FanSoundEvent_mt = Class(FanSoundEvent, Event);

InitEventClass(FanSoundEvent, "FanSoundEvent");

function FanSoundEvent:emptyNew()
    local self = Event:new(FanSoundEvent_mt);
    return self;
end;

function FanSoundEvent:new(object, isOn)
    local self = FanSoundEvent:emptyNew()
    self.object = object;
	self.isOn = isOn;
    return self;
end;

function FanSoundEvent:readStream(streamId, connection)
	self.object = readNetworkNodeObject(streamId);
	self.isOn = streamReadBool(streamId);
    self:run(connection);
end;

function FanSoundEvent:writeStream(streamId, connection)
	writeNetworkNodeObject(streamId, self.object);
	streamWriteBool(streamId, self.isOn);
end;

function FanSoundEvent:run(connection)
	if self.object ~= nil then
		FanSound.toggleSound(self.object, self.isOn, true);
		if not connection:getIsServer() then
			g_server:broadcastEvent(FanSoundEvent:new(self.object, self.isOn), nil, connection, self.object);
		end;
	end;
end;
