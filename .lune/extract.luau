--recycled script from last project for extracting assets
--#selene: allow(incorrect_standard_library_use))
local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local placePath = process.args[1]
local outputPath = process.args[2]

assert(outputPath, "Output path is required")
local placeInstance = roblox.deserializePlace(fs.readFile(placePath))

local SERVICE_LOOKUP = {
	ReplicatedStorage = "shared",
	ServerScriptService = "server",
	StarterPlayer = "client",
	Workspace = "workspace",
}

local function getScriptExtension(instance)
	if instance.ClassName == "ModuleScript" then
		return ".luau"
	elseif instance.ClassName == "LocalScript" then
		return ".client.luau"
	elseif instance.ClassName == "Script" then
		return ".server.luau"
	else
		return ".luau"
	end
end

local function isFolderLike(instance)
	local folderLikeClasses = {
		["Folder"] = true,
		["StarterPlayer"] = true,
		["StarterPlayerScripts"] = true,
		["StarterCharacterScripts"] = true,
		["ReplicatedStorage"] = true,
		["ServerScriptService"] = true,
		["Workspace"] = true,
	}

	return folderLikeClasses[instance.ClassName] or false
end

local function saveInstance(path, instance)
	if isFolderLike(instance) then
		local dirPath = path .. "/" .. instance.Name
		fs.writeDir(dirPath)
		for _, child in ipairs(instance:GetChildren()) do
			saveInstance(dirPath, child)
		end
	elseif instance:IsA("Model") then
		local modelData = roblox.serializeModel({ instance }, true)
		local filePath = path .. "/" .. instance.Name .. ".rbxmx"
		fs.writeFile(filePath, modelData)
	elseif instance:IsA("LuaSourceContainer") then
		local ext = getScriptExtension(instance)
		local filePath = path .. "/" .. instance.Name .. ext
		fs.writeFile(filePath, instance.Source)
	else
		local miscPartData = roblox.serializeModel({ instance }, true)
		local filePath = path .. "/" .. instance.Name .. ".rbxmx"
		fs.writeFile(filePath, miscPartData)
	end
end

fs.writeDir(outputPath)

for serviceName, folderName in pairs(SERVICE_LOOKUP) do
	local service = placeInstance:GetService(serviceName)
	if service then
		local servicePath = outputPath .. "/" .. folderName
		fs.writeDir(servicePath)

		-- Special handling for StarterPlayer to extract StarterPlayerScripts
		if serviceName == "StarterPlayer" then
			local starterPlayerScripts = service:FindFirstChild("StarterPlayerScripts")
			if starterPlayerScripts then
				for _, child in ipairs(starterPlayerScripts:GetChildren()) do
					saveInstance(servicePath, child)
				end
			end
		else
			for _, child in ipairs(service:GetChildren()) do
				saveInstance(servicePath, child)
			end
		end
	end
end
