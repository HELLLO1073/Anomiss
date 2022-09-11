_G.BeamSettings = {Enabled = true, StartColor = Color3.new(0.882352, 0, 1),EndColor = Color3.new(1, 1, 1),StartWidth = 0.1,EndWidth = 0.05,Time = 1}
_G.AimSettings = {Enabled = false, Checks = {TeleBullet = true}}
_G.AimTarget = {Part = nil}

local BeamPart = Instance.new("Part", workspace)    
BeamPart.Name = "BeamPart"
BeamPart.Transparency = 1

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CCamera = workspace.CurrentCamera

local function HitDetection(character, part)
    if _G.hitmanager.hitsounds.Enabled and character then
        local hitplayer = nil
        if workspace:FindFirstChild("HitsoundX2") then
            hitplayer = workspace.HitsoundX2
            hitplayer.Volume =  _G.hitmanager.hitsounds.Volume
            hitplayer.SoundId = _G.hitmanager.hitsounds.ID
        else
            hitplayer = Instance.new("Sound", workspace)
            hitplayer.Name = "HitsoundX2"
            hitplayer.Volume =  _G.hitmanager.hitsounds.Volume
            hitplayer.SoundId = _G.hitmanager.hitsounds.ID
        end
        hitplayer:Play()
    end
end

local function Beam(origin, end_part)        
    if _G.BeamSettings.Enabled then
        local colorSequence = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(225, 0, 255)),ColorSequenceKeypoint.new(1, _G.BeamSettings.EndColor),})
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
        Beam.LightInfluence = 0
        Beam.Width0 = _G.BeamSettings.StartWidth
        Beam.Width1 = _G.BeamSettings.EndWidth  

        delay(_G.BeamSettings.Time, function()        
            for i = 0.5, 1, 0.02 do
                wait()
                Beam.Transparency = NumberSequence.new(0)
            end
            Part:Destroy()
            Attachment2:Destroy()
        end)
    end
end

local oldNamecall, oldIndex
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local CallingScript = getcallingscript()
    local Arguments = {...}
    local self = Arguments[1]  

    if _G.AimSettings.Enabled and tostring(self) == "Workspace" then 
        if LocalPlayer.Character and game.FindFirstChild(LocalPlayer.Character, "Head") and _G.AimTarget and _G.AimTarget.Part then       
            if tostring(Method) == "FindPartOnRay" and tostring(CallingScript) == "MainGunScript"  then
                local CurrentRay = Arguments[2] 
                local origin = CurrentRay.Origin              
                
                if _G.AimSettings.Checks.TeleBullet then
                    local randpoints = {Vector3.new(0.7, 0, 0), Vector3.new(0, 0, 0.7)}
                    local tpoint = _G.AimTarget.Part.Position + randpoints[math.random(1, #randpoints)]                       
                    
                    task.spawn(Beam, origin, _G.AimTarget.Part)                           
                    Arguments[2] = Ray.new(tpoint, (_G.AimTarget.Part.Position-tpoint).Unit * 5000)    
                else
                    Arguments[2] = Ray.new(origin, (_G.AimTarget.Part.Position-origin).Unit * 5000)
                end
               
                return oldNamecall(unpack(Arguments))   
            end 
        end
    end  

    if tostring(Method) == "FindPartOnRayWithWhitelist" and CallingScript == LocalPlayer.PlayerGui["_L.Handler"].GunHandlerLocal then
        wait(9e9)
        return
    end

    if tostring(Method) == "FindPartOnRayWithIgnoreList" and CallingScript.Name == "MainGunScript" then
        return true
    end

    if tostring(Method) == "FireServer" and tostring(self) == "WeaponServer" and tostring(Arguments[2]) == "Player" then
        local character = Arguments[3].Parent
        local hitpart = Arguments[5]

        if _G.hitmanager.hitsounds.Enabled then
            task.spawn(HitDetection, Arguments[3].Parent, hitpart)
        end

        if _G.hitmanager.alwayshead and tostring(hitpart) ~= "Head" then
            Arguments[5] = character.Head
            return oldNamecall(unpack(Arguments))
        end
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
