-- // Simple anti-car

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local signalConnection = nil

coroutine.wrap(function()
    while true do 
        if _G.Anticar then        
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local HumanoidRoot = LocalPlayer.Character.HumanoidRootPart
            local Humanoid = LocalPlayer.Character.Humanoid
            
            if Humanoid.Health > 0.0 and HumanoidRoot then
                    if HumanoidRoot:FindFirstChildOfClass("TouchTransmitter") then
                        HumanoidRoot:FindFirstChildOfClass("TouchTransmitter"):Destroy()
                    end
                end

                if signalConnection == nil then
                    signalConnection = Humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
                        if Humanoid.Sit then
                            Humanoid.Sit = false
                        end
                    end)
                end

            elseif not LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Humanoid") and signalConnection ~= nil then
                signalConnection:Disconnect()
                signalConnection = nil
            end
        end
        task.wait(0.1)
    end
end)()
