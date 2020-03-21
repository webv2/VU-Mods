class 'ConsoleVehiclesServer'

function ConsoleVehiclesServer:__init()
	print("Initializing ConsoleVehiclesServer")
	self:RegisterVars()
	self:RegisterEvents()
end

function ConsoleVehiclesServer:RegisterVars()
	self.vehicleTable = {}
end


function ConsoleVehiclesServer:RegisterEvents()
	Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
	NetEvents:Subscribe('VehicleWeapons:SpawnVehicle', self, self.OnSpawnVehicle)
end

-- Store the name of every vehicleBlueprint that gets loaded
function ConsoleVehiclesServer:OnPartitionLoaded(partition)
	local instances = partition.instances

	for _, instance in pairs(instances) do

		if instance.typeInfo.name == 'VehicleBlueprint' then
			
			local vehicleBlueprint = VehicleBlueprint(instance)
			
			-- Vehicles/AH6/AH6_Littlebird --> AH6_Littlebird
			local vehicleName = vehicleBlueprint.name:gsub(".+/.+/",""):gsub("_","-")
		
			self.vehicleTable[vehicleName] = vehicleBlueprint
		end
	end
end


function ConsoleVehiclesServer:OnSpawnVehicle(player, args)
	
	-- If no second argument is specified (arg[2] == nil) distance is set to 5
	local distance = args[2] or 5
	
	local height = args[3] or 0
	
	-- Use the players yaw (0 to 2*pi) to spawn the vehicle in the direction the player is looking
	local yaw = player.input.authoritativeAimingYaw
	
	local transform = LinearTransform()
	
	transform.trans.x = player.soldier.transform.trans.x + (math.cos(yaw + (math.pi/2)) * distance)
	transform.trans.y = player.soldier.transform.trans.y + height
	transform.trans.z = player.soldier.transform.trans.z + (math.sin(yaw + (math.pi/2)) * distance)
	
	local params = EntityCreationParams()
	params.transform = transform
	params.networked = true

	local blueprint = self.vehicleTable[args[1]]
	
	local vehicles = EntityManager:CreateEntitiesFromBlueprint(blueprint, params)
	for i, entity in ipairs(vehicles) do
		entity:Init(Realm.Realm_ClientAndServer, true)
	end
end


g_ConsoleVehiclesServer = ConsoleVehiclesServer()
