local LocalPlayer = game.Players.LocalPlayer
local CCamera = workspace.CurrentCamera

local Settings = {
    EndColor = Color3.new(1, 1, 1),
    StartWidth = 0.1,
    EndWidth = 0.05,    
    Time = 1
}

local BeamPart = Instance.new("Part", workspace)    
BeamPart.Name = "BeamPart"
BeamPart.Transparency = 1

local function Beam(origin, end_part)    
    if _G.beams.Enabled then
        
        local colorSequence = ColorSequence.new({ColorSequenceKeypoint.new(0, _G.beams.Color),ColorSequenceKeypoint.new(1, Settings.EndColor),})
        local Part = Instance.new("Part", BeamPart)

        Part.Size = Vector3.new(1, 1, 1)
        Part.Transparency = 1
        Part.CanCollide = false
        Part.CFrame = CFrame.new(origin)
        Part.Anchored = true

        local Attachment = Instance.new("Attachment", Part)        

        local Attachment2 = Instance.new("Attachment", end_part)
        local Beam = Instance.new("Beam", Part)

        Beam.FaceCamera = true
        Beam.Color = colorSequence
        Beam.Attachment0 = Attachment
        Beam.Attachment1 = Attachment2
        Beam.LightEmission = 6
        Beam.LightInfluence = 1
        Beam.Width0 = Settings.StartWidth
        Beam.Width1 = Settings.EndWidth  

        delay(Settings.Time, function()        
            for i = 0.5, 1, 0.02 do
                wait()
                Beam.Transparency = NumberSequence.new(i)
            end
            Part:Destroy()
            Attachment2:Destroy()
        end)

    end
end   

local function CorrectArguments(Args)
    local Matching = 0
    local Required = 2
    local TypeList = {"Instance", "Ray", "Instance", "boolean", "boolean"}

    if #Args < Required then
        return false    
    end

    for i, a in next, Args do
        if typeof(a) == TypeList[i] then
            Matching = Matching + 1
        end
    end   

    return Matching >= Required
end

local RayCastLength = 4500
local oldNamecall, oldIndex
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local CallingScript = getcallingscript()
    local Arguments = {...}
    local self = Arguments[1]

    local ray_origin = nil       

    if _G.silent.Enabled and tostring(self) == "Workspace" then 

        if _G.silent.hitpart ~= nil and LocalPlayer.Character and game.FindFirstChild(LocalPlayer.Character, "Head") then                 

            if _G.silent.origin == "Camera" then
                ray_origin = CCamera.CFrame.Position
            elseif _G.silent.origin == "MyHead" then
                ray_origin = game.FindFirstChild(LocalPlayer.Character, "Head").Position                              
            elseif _G.silent.origin == "Teleport" then
                ray_origin = _G.silent.hitpart.Position + Vector3.new(0,1,0)               
            end

            if tostring(Method) == "FindPartOnRay" and CorrectArguments(Arguments) then
                local CurrentRay = Arguments[2] 
                local origin = CurrentRay.Origin              

                if _G.silent.origin == "Called" then
                    Arguments[2] = Ray.new(origin, (_G.silent.hitpart.Position-origin).Unit * RayCastLength)                
                    task.spawn(Beam, origin, _G.silent.hitpart) 
                else
                    Arguments[2] = Ray.new(ray_origin, (_G.silent.hitpart.Position-ray_origin).Unit * RayCastLength)            
                    task.spawn(Beam, ray_origin, _G.silent.hitpart)     
                end             

                return oldNamecall(unpack(Arguments))   
            end 
        end
    end  

    if tostring(Method) == "FindPartOnRayWithWhitelist" and CallingScript == LocalPlayer.PlayerGui["_L.Handler"].GunHandlerLocal then
        wait(9e9)
        return
    end

    if _G.flightshot and tostring(Method) == "FindPartOnRayWithIgnoreList" and CallingScript.Name == "MainGunScript" then
        return true
    end

    if Method == "Kick" then		
		return nil                    
	end 
    
    return oldNamecall(...)
end))

oldIndex = hookmetamethod(game, "__index", newcclosure(function(Self, index)

    if tostring(Self) == "Humanoid" then
        if index == "WalkSpeed" then
            return 13
        end
        if index == "JumpPower" then
            return 30
        end
    end

    return oldIndex(Self, index)
end))