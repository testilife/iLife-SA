-- #######################################
-- ## Project: MTA iLife				##
-- ## Name: TrainCrossing.lua					##
-- ## Author: Noneatme					##
-- ## Version: 1.0						##
-- ## License: See top Folder			##
-- #######################################

-- FUNCTIONS / METHODS --

local cFunc = {};		-- Local Functions
local cSetting = {};	-- Local Settings

TrainCrossing = {};
TrainCrossing.__index = TrainCrossing;

--[[

]]

-- ///////////////////////////////
-- ///// New 				//////
-- ///// Returns: Object	//////
-- ///////////////////////////////

function TrainCrossing:New(...)
	local obj = setmetatable({}, {__index = self});
	if obj.Constructor then
		obj:Constructor(...);
	end
	return obj;
end

-- ///////////////////////////////
-- ///// MoveUp		 		//////
-- ///// Returns: void		//////
-- ///////////////////////////////

function TrainCrossing:MoveUp()
	if(self.state == false) then
		if(self.moving) then
			killTimer(self.movingTimer)
		end
		for i = 1, self.maxSchranken, 1 do
			if(self.moving) then
				stopObject(self.schranke[i])
				setElementPosition(self.schranke[i], self.standartPos[i][2], self.standartPos[i][3], self.standartPos[i][4]-1.5)
			end
			local x, y, z = getElementPosition(self.schranke[i])
			moveObject(self.schranke[i], self.moveTime, x, y, z+1.5, 0, 0, 0);
			
				
			if(isElement(self.crossSound[i])) then
				destroyElement(self.crossSound[i])
			end
			
			self.crossSound[i] = playSound3D("res/sounds/train/railroad.mp3", self.standartPos[i][2], self.standartPos[i][3], self.standartPos[i][4], true);
			setSoundMaxDistance(self.crossSound[i], 50)
		end
		self.moving = true;
		self.movingTimer = setTimer(function() self.moving = false end, self.moveTime, 1);

		self.state = not (self.state);
	end
end

-- ///////////////////////////////
-- ///// MoveDown	 		//////
-- ///// Returns: void		//////
-- ///////////////////////////////

function TrainCrossing:MoveDown()
	if(self.state == true) then
		if(self.moving) then
			killTimer(self.movingTimer)
		end
		for i = 1, self.maxSchranken, 1 do
			if(self.moving) then
				stopObject(self.schranke[i])
				setElementPosition(self.schranke[i], self.standartPos[i][2], self.standartPos[i][3], self.standartPos[i][4])
			end
			local x, y, z = getElementPosition(self.schranke[i])
			moveObject(self.schranke[i], self.moveTime, x, y, z-1.5, 0, 0, 0);
			
			if(isElement(self.crossSound[i])) then
				destroyElement(self.crossSound[i])
			end
		end
		self.moving = true;
		self.movingTimer = setTimer(function() self.moving = false end, self.moveTime, 1);

		self.state = not (self.state);
		
		
	end
end

-- ///////////////////////////////
-- ///// ColShapeHit 		//////
-- ///// Returns: void		//////
-- ///////////////////////////////

function TrainCrossing:ColShapeHit(element, dim)
	if(dim == true) then
		if(self.state == false) then
			if(isElement(element)) and (getElementType(element) == "vehicle") and (self.trainHelper:IsTrain(getElementModel(element))) then
				self:MoveUp();
			end
		end
	end
end
-- ///////////////////////////////
-- ///// ColShapeLeave		//////
-- ///// Returns: void		//////
-- ///////////////////////////////

function TrainCrossing:ColShapeLeave(element, dim)
	if(dim == true) then
		if(self.state == true) then
			local runterDamit = true;

			for index, vehicle in pairs(getElementsWithinColShape(self.colShape, "vehicle")) do
				if(self.trainHelper:IsTrain(getElementModel(vehicle))) then
					runterDamit = false;
					break;
				end
			end

			if(runterDamit) then
				self:MoveDown();
			end
		end
	end
end

-- ///////////////////////////////
-- ///// Constructor 		//////
-- ///// Returns: void		//////
-- ///////////////////////////////

function TrainCrossing:Constructor(tblSchranke1, tblSchranke2, iRadius)
	-- Klassenvariablen --

	self.schranke = {}
	self.schranke[1] 			= createObject(unpack(tblSchranke1));
	self.schranke[2] 			= createObject(unpack(tblSchranke2));

	self.standartPos = {}
	self.standartPos[1]			= tblSchranke1;
	self.standartPos[2]			= tblSchranke2;
	
	self.crossSound 			= {}

	self.moving 				= false;
	self.movingTimer			= nil;

	self.maxSchranken 			= #self.schranke;

	self.radius 				= iRadius or 50;

	self.state 					= true;	-- Ist Oben
	self.moveTime 				= 3000;

	self.colShape 				= createColSphere(tblSchranke1[2], tblSchranke1[3], tblSchranke1[4], self.radius)
	self.trainHelper			= TrainHelper:New();

	-- Methoden --
	self.moveUpFunc 			= function() self:MoveUp() end;
	self.moveDownFunc 			= function() self:MoveDown() end;
	self.resetMoveStateFunc 	= function() self:ResetMoveState() end;


	self.ColShapeHitFunc		= function(...) self:ColShapeHit(...) end;
	self.ColShapeLeaveFunc		= function(...) self:ColShapeLeave(...) end;

	-- Events --

	addEventHandler("onClientColShapeHit", self.colShape, self.ColShapeHitFunc)
	addEventHandler("onClientColShapeLeave", self.colShape, self.ColShapeLeaveFunc)

	self:MoveDown();
--logger:OutputInfo("[CALLING] TrainCrossing: Constructor");
end

-- EVENT HANDLER --
