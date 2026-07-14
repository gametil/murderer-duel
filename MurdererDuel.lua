--[[ Murderer Duel — Avatar Rendering Fix
Fixes white/gray rectangle artifact on character
]]

local LP = game:GetService("Players").LocalPlayer
local char = LP.Character or LP.CharacterAdded:Wait()
local removed = {accessories = 0, decals = 0, guis = 0, highlights = 0, welds = 0}

-- 1) Remove broken accessories (unreviewed mesh = gray box)
local function cleanAccessories()
    for _, v in ipairs(char:GetDescendants()) do
        -- Accessory Handle with broken mesh
        if v:IsA("Accessory") or v.Name == "Accessory" then
            local handle = v:FindFirstChild("Handle")
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh") or handle:FindFirstChildOfClass("MeshPart")
                if mesh then
                    -- Remove if mesh asset unreviewed or broken
                    if mesh.MeshId and (mesh.MeshId == "" or mesh.MeshId:find("rbxassetid://0")) then
                        v:Destroy()
                        removed.accessories = removed.accessories + 1
                    end
                end
            end
        end
        
        -- Also kill any oversized flat MeshPart (typical artifact)
        if v:IsA("MeshPart") and v.Parent and v.Parent:FindFirstAncestorOfClass("Accessory") then
            local s = v.Size
            if s.X > 10 or s.Y > 10 or s.Z > 10 then
                v:Destroy()
                removed.accessories = removed.accessories + 1
            end
        end
    end
end

-- 2) Remove broken Decals on character parts
local function cleanDecals()
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Decal") and v.Parent and v.Parent:IsA("BasePart") then
            if v.Texture == "" or v.Texture:find("rbxassetid://0") then
                v:Destroy()
                removed.decals = removed.decals + 1
            end
        end
    end
end

-- 3) Remove SurfaceGuis / BillboardGuis stuck on body (causes white squares)
local function cleanGuis()
    for _, v in ipairs(char:GetDescendants()) do
        if (v:IsA("SurfaceGui") or v:IsA("BillboardGui")) then
            v:Destroy()
            removed.guis = removed.guis + 1
        end
    end
end

-- 4) Remove Highlight instances (broken highlights = white glow)
local function cleanHighlights()
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Highlight") then
            v:Destroy()
            removed.highlights = removed.highlights + 1
        end
    end
end

-- 5) Find oversized/corrupted parts on character
local function cleanOversized()
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.Parent ~= char then
            local s = v.Size
            local vol = s.X * s.Y * s.Z
            -- Any part with absurd volume that's not a body part
            if vol > 500 and v.Name ~= "Head" and v.Name ~= "Torso" and v.Name ~= "HumanoidRootPart" and v.Name ~= "Handle" then
                v:Destroy()
                removed.accessories = removed.accessories + 1
            end
        end
    end
end

-- 6) Fix broken WeldConstraints
local function fixWelds()
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("WeldConstraint") then
            if not v.Part0 or not v.Part1 then
                v:Destroy()
                removed.welds = removed.welds + 1
            end
        end
    end
end

-- Run all fixers
cleanAccessories()
cleanDecals()
cleanGuis()
cleanHighlights()
cleanOversized()
fixWelds()

-- Recalculate appearance
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then
    hum:SetAttribute("ForceRerender", true)
    pcall(function()
        hum:BuildRigFromAttachments()  -- resets accessories
    end)
end

warn("[[ FIX ]] Removed " .. removed.accessories .. " broken accessories, " .. removed.decals .. " decals, " .. removed.guis .. " GUIs, " .. removed.highlights .. " highlights")
