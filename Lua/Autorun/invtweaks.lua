InvTweaks = InvTweaks or {}

InvTweaks.IsDragging = false
InvTweaks.WasDragging = false

InvTweaks.Source = {
    Items = nil,
    Slot = nil,
    Inventory = nil,
}

Inventory = LuaUserData.CreateStatic('Barotrauma.Inventory')

-- OwnInventory = function() return Character.Controlled and Character.Controlled.Inventory end
-- OwnCharacter = function() return Character.Controlled end
 

Hook.Add("keyUpdate", "InvTweaks_keyUpdate", function(dtime)
    --print(PlayerInput.PrimaryMouseButtonClicked)
    --PlayerInput.primaryDoubleClicked = false
    --doubleClickedItems.Clear()
    if PlayerInput.PrimaryMouseButtonDown() then
        InvTweaks.SaveSource()
        --InvTweaks.UpdateDragging()
        --print(Inventory.DraggingSlot.MouseOn())
        --Hook.Call("InvTweaks.Hooks.PrimaryPressed", {"some", "arguments", 123})
        return
    end

    if PlayerInput.PrimaryMouseButtonClicked() then
        Hook.Call("InvTweaks.Hooks.PrimaryReleased", {"some", "arguments", 123})
        return
    end

    if PlayerInput.KeyHit(Keys.J) then
        Hook.Call("InvTweaks.Hooks.Debug")
    end

    
    return
end)

Inventory = LuaUserData.CreateStatic('Barotrauma.Inventory')

Hook.Add("InvTweaks.Hooks.Debug", "InvTweaks_Debug", function(dtime)
    --Game.GameSession.CrewManager.AddSinglePlayerChatMessage("", Inventory.DraggingSlot and tostring(Inventory.DraggingSlot.State) or "Nil", ChatMessageType.Private, Character.Controlled)
    Game.GameSession.CrewManager.AddSinglePlayerChatMessage("", InvTweaks.IsDragging(), ChatMessageType.Private, Character.Controlled) 


end)

Hook.Add("InvTweaks.Hooks.PrimaryReleased", "InvTweaks_PrimaryLogic", function(dtime)
    InvTweaks.UpdateOwner()

    --print(InvTweaks.GetHoveredItems())

    if not InvTweaks.GetHoveredSlot() or InvTweaks.IsDragging() then return end
    
    -- if Inventory.DraggingItems ~= nil and Inventory.DraggingItems[1] ~= nil then
    -- if Inventory.DraggingSlot == nil or (not Inventory.DraggingSlot.MouseOn())


    local HoveredInventory = InvTweaks.GetHoveredInventory()
    local HoveredItems = InvTweaks.GetHoveredItems()
    --print(InvTweaks.IsInventoryClientOwned(HoveredInventory))
    local targetInventory = InvTweaks.IsInventoryClientOwned(HoveredInventory) and InvTweaks.GetSelectedInventory() or InvTweaks.OwnInventory
    --print(InvTweaks.GetSelectedInventory())

    if PlayerInput.KeyDown(InputType.TakeHalfFromInventorySlot) then
        InvTweaks.TryPutItems(HoveredItems, targetInventory)
    elseif PlayerInput.KeyDown(InputType.TakeOneFromInventorySlot) then
        InvTweaks.TryPutItem(HoveredItems[1], targetInventory)
    end
    --print("AAAAAAAAAA")

    --Game.GameSession.CrewManager.AddSinglePlayerChatMessage("", Inventory.DraggingSlot and tostring(Inventory.DraggingSlot.State) or "Nil", ChatMessageType.Private, Character.Controlled) 
    InvTweaks.ClearSource()
end)



-- LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.PlayerInput'], 'AllowInput')
-- LuaUserData.MakeFieldAccessible(Descriptors['Barotrauma.PlayerInput'], 'primaryDoubleClicked')

Hook.Patch("InvTweaks_DoubleClickOverride", "Barotrauma.PlayerInput", "DoubleClicked", function(instance, ptable)
    -- ptable.PreventExecution = true
    -- if PlayerInput.AllowInput and not InvTweaks.IsModifierKeyHeld() then
    --     return PlayerInput.primaryDoubleClicked
    -- end
    -- return false
    ptable.ReturnValue = ptable.ReturnValue and not InvTweaks.IsModifierKeyHeld()
end, Hook.HookMethodType.After)

--if true then return end

---Returns a boolean indicating whether a given item is affected or not.
---@param identifier string The identifier of the item that we are testing.
---@return boolean isAffected True if the item is affected, false otherwise.

---@param char1 Barotrauma_Character Character one.
---@param char2 Barotrauma_Character Character two.
---@return boolean charactersAreOnSameTeam True if characters one & two are on the same team, false otherwise.
--function isOnSameTeam(char1, char2)


-- Prototype to describe what i want to have accessible and autoinstantiated in a custom table of diffrent inventories. 
-- This is meant to work with inventories directly without having to constantly get Item.OwnInventories yada yada
-- So structuraly its an Inventory of Slots containing Inventories or Items


-- BaseInventory = {}

-- BaseSlot = {
--     Item = {
--         IsContainer = bool
--         HasAccesibleSlots = bool
--         Inventories = {inventory,inventory}
--         Inventory = Inventories:Combine()
--     },
--     Inventory = {},
--     Inventories = {},

-- }

-- function InvTweaks.IsItemContainer(item)

-- end

-- function InvTweaks.GetCharacterInventory(character)

-- end

-- function InvTweaks.ItemHasAccesibleSlots(item)
-- end

-- function InvTweaks.GetInventory(item)
-- end

-- function InvTweaks.GetRootContainer(item)
-- end

-- function InvTweaks.GetSlot(item_or_inventory, slotindex)
-- end


---Refreshes InvTweaks.OwnCharacter and InvTweaks.OwnInventory values
function InvTweaks.UpdateOwner()
    InvTweaks.OwnCharacter = Character.Controlled
    InvTweaks.OwnInventory = Character.Controlled and Character.Controlled.Inventory
end



---@return bool returns true if source item is currently being dragged
function InvTweaks.IsDragging()
    --return Inventory.DraggingSlot ~= nil and (not Inventory.DraggingSlot.MouseOn())
    --mouse not over the source slot
    return InvTweaks.Source.Slot ~= nil and (not InvTweaks.Source.Slot.Slot.MouseOn())
end

---Sets InvTweaks.Source values to currently hovered slot/items/inventory
function InvTweaks.SaveSource()
    InvTweaks.Source.Items = InvTweaks.GetHoveredItems()
    InvTweaks.Source.Slot = InvTweaks.GetHoveredSlot()
    InvTweaks.Source.Inventory = InvTweaks.GetHoveredInventory()
end

---Clears InvTweaks.Source
function InvTweaks.ClearSource()
    InvTweaks.Source.Items = nil
    InvTweaks.Source.Slot = nil
    InvTweaks.Source.Inventory = nil
end

---@return Barotrauma.Inventory.SlotReference returns slot which is currently being hovered over by client mouse or nil.
function InvTweaks.GetHoveredSlot()
    return Inventory.SelectedSlot
end

---@return Barotrauma.Inventory returns inventory which contains the slot which is currently being hovered over by client mouse or nil.
function InvTweaks.GetHoveredInventory()
    return InvTweaks.GetHoveredSlot() and InvTweaks.GetHoveredSlot().ParentInventory
end

---@return Barotrauma.Inventory returns inventory of the item/character currently being interacted with by client character or nil.
function InvTweaks.GetSelectedInventory()
    if InvTweaks.GetSelectedItem() then
        return InvTweaks.GetSelectedItem().OwnInventory
    elseif InvTweaks.GetSelectedCharacter() then
        return InvTweaks.GetSelectedCharacter().Inventory
    end
end

---@return Barotrauma.Inventory returns item currently being interacted with by client character or nil.
function InvTweaks.GetSelectedItem()
    return InvTweaks.OwnCharacter and InvTweaks.OwnCharacter.SelectedItem
end

function InvTweaks.GetSelectedCharacter()
    return InvTweaks.OwnCharacter and InvTweaks.OwnCharacter.SelectedCharacter
end

---@return bool returns true if shift,ctrl or alt key/s are held
function InvTweaks.IsModifierKeyHeld()
    return PlayerInput.KeyDown(InputType.TakeHalfFromInventorySlot) 
    or PlayerInput.KeyDown(InputType.TakeOneFromInventorySlot) 
    or PlayerInput.KeyDown(InputType.ShowInteractionLabels)
end

---@param Barotrauma.Item/Barotrauma.inventory/Barotrauma.Inventory.SlotReference object item or inventory or slot
---@return bool returns true if item or inventory or slot are contained inside of client character inventory.
function InvTweaks.IsClientOwned(object)


end



---@param Barotrauma.inventory inventory
---@return bool returns true if inventory is contained inside of client character inventory.
function InvTweaks.IsInventoryClientOwned(inventory)
    return inventory == InvTweaks.OwnInventory or LuaUserData.IsTargetType(inventory.Owner, "Barotrauma.Item") and (inventory.Owner.GetRootInventoryOwner() == InvTweaks.OwnCharacter)
end

--TODO: should countInaccessibleSlots ?
---@return bool
function InvTweaks.IsContainer(item, countInaccessibleSlots)
    countInaccessibleSlots = countInaccessibleSlots or false
    return item.OwnInventory ~= nil
end

---@return IEnumerable<Barotrauma.Item> returns array of items which are contained in the slot which is currently being hovered over by client mouse or empty array.
function InvTweaks.GetHoveredItems()
    local slot = InvTweaks.GetHoveredSlot()
    if slot and slot.ParentInventory then 
       return slot.ParentInventory.GetItemsAt(slot.SlotIndex)
    end
    return {}
end

---Attempt to move an item to inventory
---@param Barotrauma.Item item item to move
---@param Barotrauma.Inventory inventory to which inventory to try move item
---@return bool returns true if item was successfully moved
function InvTweaks.TryPutItem(item, inventory)
    if LuaUserData.IsTargetType(inventory, "Barotrauma.ItemInventory") then
        return inventory.TryPutItem(item, InvTweaks.OwnCharacter)
    else --if LuaUserData.IsTargetType(inventory, "Barotrauma.CharacterInventory")
        return inventory.TryPutItem(item, InvTweaks.OwnCharacter, CharacterInventory.AnySlot)
    end
end

---Attempt to move array of items to inventory
---@param {Barotrauma.Item} items items to move
---@param Barotrauma.Inventory inventory to which inventory to try move items
---@return bool returns true if all items were moved otherwise false
function InvTweaks.TryPutItems(items, inventory)
    local movedEverything = true
    if LuaUserData.IsTargetType(inventory, "Barotrauma.ItemInventory") then
        for item in items do
            movedEverything = inventory.TryPutItem(item, InvTweaks.OwnCharacter) and movedEverything
        end
    else --if LuaUserData.IsTargetType(inventory, "Barotrauma.CharacterInventory")
        for item in items do
            movedEverything = inventory.TryPutItem(item, InvTweaks.OwnCharacter, CharacterInventory.AnySlot) and movedEverything
        end
    end
    
    return movedEverything
end















---Attempts to move item out of client character inventory
---@param Barotrauma.Item item item to deposit
---@param Barotrauma.Inventory inventory to which inventory to try move item
---@return bool returns true if item was moved otherwise false
function InvTweaks.DepositItem(item, inventory)
    return Inventory.SelectedSlot and Inventory.SelectedSlot.Item
end

---Attempt to move item to client character inventory
---@param Barotrauma.Item item item to take
---@return bool returns true if item was moved otherwise false
function InvTweaks.TakeItem(item)
    return Inventory.SelectedSlot and Inventory.SelectedSlot.Item
end

---Attempt to move item to client character inventory
---@param Barotrauma.Item item item to take
---@return bool returns true if item was moved otherwise false
function InvTweaks.TakeStack(item)
    return Inventory.SelectedSlot and Inventory.SelectedSlot.Item
end