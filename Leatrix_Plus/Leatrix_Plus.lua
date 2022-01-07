----------------------------------------------------------------------
-- 	L00: Leatrix Plus 5.4.14 (4th June 2014) (www.leatrix.com)
---------------------------------------------------------------------- 
--[[
		00: Start					Shows where everything is
		01: Locks					Enables and disables panel controls
		02: Restarts				Sets the reload button state
		03: Functions				Generic functions used throughout the addon
		04: Load and save			Loads and saves settings

		20: Live					Runs after ADDON_LOADED and when a panel control is clicked
		30: Isolated code			Runs after ADDON_LOADED (32 is tooltip)
		40: Variable				Runs after VARIABLES_LOADED (42 is frames)	 		
		50: Player					Runs after PLAYER_ENTERING_WORLD

		60: BlizzDep				Runs after a required Blizzard addon has loaded
		62: RunOnce					Runs after ADDON_LOADED (typically code without functions)
		64: Events					Runs after a registered event has fired
		66: Player logout			Runs when the UI reloads or player logs out
		70: Slash commands			Slash command handler

		75: Panel functions			Functions used for creating the options panel	
		76: Main panel template		Creates the main options panel (77 is page templates)		
		80: Page content			Populates the panel pages
]]
----------------------------------------------------------------------
-- 	Leatrix Plus
----------------------------------------------------------------------

--  Create global tables if they don't exist
	LeaPlusDB = LeaPlusDB or {}
	LeaPlusDC = LeaPlusDC or {}

-- 	Create local tables to store configuration and frames
	local LeaPlusLC = {}
	local LeaPlusCB = {}
	local LeaDropList = {}
	local void

--	Version control
	LeaPlusLC["AddonVer"] = "5.4.14"
	LeaPlusLC["InterfaceVer"] = "50400"

--	Initialise variables
	LeaPlusLC["ShowErrorsFlag"] = 1
	LeaPlusLC["NumberOfPages"] = 8
	LeaPlusLC["RaidColors"] = RAID_CLASS_COLORS

--	Create event frame
	local LpEvt = CreateFrame("FRAME")
	LpEvt:RegisterEvent("ADDON_LOADED")
	LpEvt:RegisterEvent("VARIABLES_LOADED")
	LpEvt:RegisterEvent("PLAYER_ENTERING_WORLD")
	LpEvt:RegisterEvent("PLAYER_LOGOUT")

----------------------------------------------------------------------
--	L01: Locks
----------------------------------------------------------------------

-- 	Lock and unlock individual items
	function LeaPlusLC:LockItem(item,lock)
		if lock then
			item:Disable()
			item:SetAlpha(0.3)
		else
			item:Enable()
			item:SetAlpha(1.0)
		end
	end

--	Lock and dim invalid options
	function LeaPlusLC:SetDim()

		-- Whisper invite
		if LeaPlusLC["InviteFromWhisper"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["InvWhisperBtn"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["InvWhisperBtn"],false)
		end

		-- Player chains
		if (LeaPlusLC["ShowPlayerChain"] ~= LeaPlusDB["ShowPlayerChain"]) or LeaPlusLC["ShowPlayerChain"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["ModPlayerChain"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["ModPlayerChain"],false)
		end

		-- Protect privacy
		if (LeaPlusLC["AchieveControl"] ~= LeaPlusDB["AchieveControl"]) or LeaPlusLC["AchieveControl"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["CharOnlyAchieves"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["CharOnlyAchieves"],false)
		end

		-- Battle.net friend request blocking
		if (LeaPlusLC["ManageBnetReq"] ~= LeaPlusDB["ManageBnetReq"]) or LeaPlusLC["ManageBnetReq"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["BlockBnetReq"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["BlockBnetReq"],false)
		end

		-- Spell icons
		if (LeaPlusLC["ShowSpellIcons"] ~= LeaPlusDB["ShowSpellIcons"]) or LeaPlusLC["ShowSpellIcons"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["SpellIconsBtn"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["SpellIconsBtn"],false)
		end

		-- Frame options
		if (LeaPlusLC["FrmEnabled"] ~= LeaPlusDB["FrmEnabled"]) or LeaPlusLC["FrmEnabled"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["MoveFramesButton"],true)
		elseif LeaPlusLC["FrmEnabled"] == "On" then
			LeaPlusLC:LockItem(LeaPlusCB["MoveFramesButton"],false)
		end

		-- World map modification button
		if (LeaPlusLC["ShowMapMod"] ~= LeaPlusDB["ShowMapMod"]) or LeaPlusLC["ShowMapMod"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["MapOptBtn"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["MapOptBtn"],false)
		end

		-- Automatically toggle nameplates
		if (LeaPlusLC["AutoEnName"] ~= LeaPlusDB["AutoEnName"]) or LeaPlusLC["AutoEnName"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["ModEnPanelBtn"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["ModEnPanelBtn"],false)
		end

		-- Manage emote sounds
		if (LeaPlusLC["ManageRestedEmotes"] ~= LeaPlusDB["ManageRestedEmotes"]) or LeaPlusLC["ManageRestedEmotes"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["NoSoundRested"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["NoSoundRested"],false)
		end

		-- Tooltip options
		if (LeaPlusLC["TipModEnable"] ~= LeaPlusDB["TipModEnable"]) or LeaPlusLC["TipModEnable"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["MoveTooltipButton"],true)
			LeaPlusLC:LockItem(LeaPlusCB["TipAnchorToMouse"],true)
			LeaPlusLC:LockItem(LeaPlusCB["ModTipMouseBtn"],true)
			LeaPlusCB["ModTipMouseBtn"]:SetAlpha(1)

		elseif LeaPlusLC["TipModEnable"] == "On" then

			LeaPlusLC:LockItem(LeaPlusCB["MoveTooltipButton"],false)
			LeaPlusLC:LockItem(LeaPlusCB["TipAnchorToMouse"],false)
			LeaPlusLC:LockItem(LeaPlusCB["ModTipMouseBtn"],false)

			-- Anchor to mouse
			if (LeaPlusLC["TipAnchorToMouse"] ~= LeaPlusDB["TipAnchorToMouse"]) or LeaPlusLC["TipAnchorToMouse"] == "Off" then
				LeaPlusLC:LockItem(LeaPlusCB["ModTipMouseBtn"],true)
			else
				LeaPlusLC:LockItem(LeaPlusCB["ModTipMouseBtn"],false)
			end

		end

		-- Quest detail font slider lockout
		if (LeaPlusLC["QuestFontChange"] ~= LeaPlusDB["QuestFontChange"]) or LeaPlusLC["QuestFontChange"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["LeaPlusQuestFontSize"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["LeaPlusQuestFontSize"],false)
		end

		-- Mail font slider lockout
		if (LeaPlusLC["MailFontChange"] ~= LeaPlusDB["MailFontChange"]) or LeaPlusLC["MailFontChange"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["LeaPlusMailFontSize"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["LeaPlusMailFontSize"],false)
		end

		-- Automatically accept quest lockout
		if LeaPlusLC["AutoAcceptQuests"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["AcceptOnlyDailys"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["AcceptOnlyDailys"],false)
		end

		-- Automatically turn-in quest lockout
		if LeaPlusLC["AutoTurnInQuests"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["TurnInOnlyDailys"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["TurnInOnlyDailys"],false)
		end

		-- Automatic resurrection lockout
		if LeaPlusLC["AutoAcceptRes"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["NoAutoResInCombat"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["NoAutoResInCombat"],false)
		end

		-- Error frame quest lockout
		if LeaPlusLC["HideErrorFrameText"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["ShowQuestUpdates"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["ShowQuestUpdates"],false)
		end

		-- Leatrix Plus panel tooltip placement
		if LeaPlusLC["PlusShowTips"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["PanelTipAnchor"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["PanelTipAnchor"],false)
		end

		-- Leatrix Plus scale
		if LeaPlusLC["PlusPanelScaleCheck"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["LeaPlusScaleValue"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["LeaPlusScaleValue"],false)
		end

		-- Leatrix Plus alpha
		if LeaPlusLC["PlusPanelAlphaCheck"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["LeaPlusAlphaValue"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["LeaPlusAlphaValue"],false)
		end

		-- Class coloring lockout
		if (LeaPlusLC["Manageclasscolors"] ~= LeaPlusDB["Manageclasscolors"]) or LeaPlusLC["Manageclasscolors"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["ColorLocalChannels"],true)
			LeaPlusLC:LockItem(LeaPlusCB["ColorGlobalChannels"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["ColorLocalChannels"],false)
			LeaPlusLC:LockItem(LeaPlusCB["ColorGlobalChannels"],false)
		end

		-- Trade and guild block lockout
		if (LeaPlusLC["ManageTradeGuild"] ~= LeaPlusDB["ManageTradeGuild"]) or LeaPlusLC["ManageTradeGuild"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["NoTradeRequests"],true)
			LeaPlusLC:LockItem(LeaPlusCB["NoGuildInvites"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["NoTradeRequests"],false)
			LeaPlusLC:LockItem(LeaPlusCB["NoGuildInvites"],false)
		end

		-- Automated repair with guild
		if LeaPlusLC["AutoRepairOwnFunds"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["AutoRepairGuildFunds"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["AutoRepairGuildFunds"],false)
		end

		-- Viewport
		if (LeaPlusLC["ViewPortEnable"] ~= LeaPlusDB["ViewPortEnable"]) or LeaPlusLC["ViewPortEnable"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["ModViewportBtn"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["ModViewportBtn"],false)
		end

		-- Minimap customisation
		if (LeaPlusLC["MinimapMod"] ~= LeaPlusDB["MinimapMod"]) or LeaPlusLC["MinimapMod"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["ModMinimapBtn"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["ModMinimapBtn"],false)
		end

		-- Coordinates
		if (LeaPlusLC["StaticCoordsEn"] ~= LeaPlusDB["StaticCoordsEn"]) or LeaPlusLC["StaticCoordsEn"] == "Off" then
			LeaPlusLC:LockItem(LeaPlusCB["ModStaticCoordsBtn"],true)
		else
			LeaPlusLC:LockItem(LeaPlusCB["ModStaticCoordsBtn"],false)
		end

	end

----------------------------------------------------------------------
--	L02: Restarts
----------------------------------------------------------------------

	-- Set the reload button state
	function LeaPlusLC:ReloadCheck()

		-- Automation
		if	(LeaPlusLC["ManageTradeGuild"]		~= LeaPlusDB["ManageTradeGuild"])		-- Manage blockers

		-- Interaction
		or	(LeaPlusLC["NoBagAutomation"]		~= LeaPlusDB["NoBagAutomation"])		-- Prevent bag automation
		or	(LeaPlusLC["AhExtras"]				~= LeaPlusDB["AhExtras"])				-- Auction house extras
		or	(LeaPlusLC["NoRaidRestrictions"]	~= LeaPlusDB["NoRaidRestrictions"])		-- Remove raid restrictions
		or	(LeaPlusLC["RoleSave"]				~= LeaPlusDB["RoleSave"])				-- Save dungeon roles
		or	(LeaPlusLC["ShowRaidToggle"]		~= LeaPlusDB["ShowRaidToggle"])			-- Show raid toggle button
		or	(LeaPlusLC["NoLootWonAlert"]		~= LeaPlusDB["NoLootWonAlert"])			-- Hide loot won alerts
		or	(LeaPlusLC["SoilAlert"]				~= LeaPlusDB["SoilAlert"])				-- Dark Soil alert
		or	(LeaPlusLC["NoBagAutomation"]		~= LeaPlusDB["NoBagAutomation"])		-- Prevent bag automation

		-- Chat
		or	(LeaPlusLC["UseEasyChatResizing"]	~= LeaPlusDB["UseEasyChatResizing"])	-- Use easy resizing
		or	(LeaPlusLC["NoCombatLogTab"]		~= LeaPlusDB["NoCombatLogTab"])			-- Hide the combat log
		or	(LeaPlusLC["NoChatButtons"]			~= LeaPlusDB["NoChatButtons"])			-- Hide chat buttons
		or	(LeaPlusLC["UnclampChat"]			~= LeaPlusDB["UnclampChat"])			-- Unclamp chat frame
		or	(LeaPlusLC["MoveChatEditBoxToTop"]	~= LeaPlusDB["MoveChatEditBoxToTop"])	-- Move editbox to top
		or	(LeaPlusLC["NoStickyChat"]			~= LeaPlusDB["NoStickyChat"])			-- Disable sticky chat
		or	(LeaPlusLC["UseArrowKeysInChat"]	~= LeaPlusDB["UseArrowKeysInChat"])		-- Use arrow keys in chat
		or	(LeaPlusLC["NoChatFade"]			~= LeaPlusDB["NoChatFade"])				-- Disable chat fade
		or	(LeaPlusLC["MaxChatHstory"]			~= LeaPlusDB["MaxChatHstory"])			-- Increase chat history
		or	(LeaPlusLC["UnivGroupColor"]		~= LeaPlusDB["UnivGroupColor"])			-- Universal group color
		or	(LeaPlusLC["Manageclasscolors"]		~= LeaPlusDB["Manageclasscolors"])		-- Manage class colors

		-- Text
		or	(LeaPlusLC["HideZoneText"]			~= LeaPlusDB["HideZoneText"])			-- Hide zone text
		or	(LeaPlusLC["HideSubzoneText"]		~= LeaPlusDB["HideSubzoneText"])		-- Hide subzone text
		or	(LeaPlusLC["NoHitIndicators"]		~= LeaPlusDB["NoHitIndicators"])		-- Hide portrait text
		or	(LeaPlusLC["HideErrorFrameText"]	~= LeaPlusDB["HideErrorFrameText"])		-- Hide error messages
		or	(LeaPlusLC["MailFontChange"]		~= LeaPlusDB["MailFontChange"])			-- Resize mail text
		or	(LeaPlusLC["QuestFontChange"]		~= LeaPlusDB["QuestFontChange"])		-- Resize quest detail text

		-- Interface
		or	(LeaPlusLC["ShowMapMod"]			~= LeaPlusDB["ShowMapMod"])				-- Enable world map customisation
		or	(LeaPlusLC["MinimapMod"]			~= LeaPlusDB["MinimapMod"])				-- Enable minimap customisation
		or	(LeaPlusLC["FrmEnabled"]			~= LeaPlusDB["FrmEnabled"])				-- Enable frames customisation
		or	(LeaPlusLC["ShowVanityButtons"]		~= LeaPlusDB["ShowVanityButtons"])		-- Show vanity controls
		or	(LeaPlusLC["ShowVolume"]			~= LeaPlusDB["ShowVolume"])				-- Show volume control
		or	(LeaPlusLC["ShowDressTab"]			~= LeaPlusDB["ShowDressTab"])			-- Show dressup buttons
		or	(LeaPlusLC["StaticCoordsEn"]		~= LeaPlusDB["StaticCoordsEn"])			-- Show coordinates
		or	(LeaPlusLC["ShowSpellIcons"]		~= LeaPlusDB["ShowSpellIcons"])			-- Show spell icons
		or	(LeaPlusLC["DurabilityStatus"]		~= LeaPlusDB["DurabilityStatus"])		-- Show durability status

		-- Misc
		or	(LeaPlusLC["ShowQuestLevels"]		~= LeaPlusDB["ShowQuestLevels"])		-- Show quest levels
		or	(LeaPlusLC["TipModEnable"]			~= LeaPlusDB["TipModEnable"])			-- Enable tooltip customisation
		or	(LeaPlusLC["TipAnchorToMouse"]		~= LeaPlusDB["TipAnchorToMouse"])		-- Anchor tooltip to mouse
		or	(LeaPlusLC["NoGryphons"]			~= LeaPlusDB["NoGryphons"])				-- Hide gryphons
		or	(LeaPlusLC["NoClassBar"]			~= LeaPlusDB["NoClassBar"])				-- Hide stance bar
		or	(LeaPlusLC["NoCharControls"]		~= LeaPlusDB["NoCharControls"])			-- Hide character controls
		or	(LeaPlusLC["AutoEnName"]			~= LeaPlusDB["AutoEnName"])				-- Toggle enemy plates
		or	(LeaPlusLC["ClassColPlayer"]		~= LeaPlusDB["ClassColPlayer"])			-- Player in class color
		or	(LeaPlusLC["ClassColTarget"]		~= LeaPlusDB["ClassColTarget"])			-- Target in class color
		or	(LeaPlusLC["ShowPlayerChain"]		~= LeaPlusDB["ShowPlayerChain"])		-- Show player chain

		-- System
		or	(LeaPlusLC["ManageZoomLevel"]		~= LeaPlusDB["ManageZoomLevel"])		-- Max camera distance
		or	(LeaPlusLC["ViewPortEnable"]		~= LeaPlusDB["ViewPortEnable"])			-- Enable viewport
		or	(LeaPlusLC["ManageRestedEmotes"]	~= LeaPlusDB["ManageRestedEmotes"])		-- Manage emote sounds
		or	(LeaPlusLC["AchieveControl"]		~= LeaPlusDB["AchieveControl"])			-- Manage privacy
		or	(LeaPlusLC["ManageBnetReq"]			~= LeaPlusDB["ManageBnetReq"])			-- Manage friend requests

		-- Settings
		or	(LeaPlusLC["ShowMinimapIcon"]		~= LeaPlusDB["ShowMinimapIcon"])		-- Show minimap button

		-- Set the reload button state
		then
			LeaPlusLC:LockItem(LeaPlusCB["ReloadUIButton"], false)
			LeaPlusCB["ReloadUIButton"].f:Show()
		else
			LeaPlusLC:LockItem(LeaPlusCB["ReloadUIButton"], true)
			LeaPlusCB["ReloadUIButton"].f:Hide()
		end

	end

----------------------------------------------------------------------
--	L03: Functions
----------------------------------------------------------------------

	-- Print text
	function LeaPlusLC:Print(text)
		DEFAULT_CHAT_FRAME:AddMessage(text, 1.0, 0.85, 0.0)
	end

	-- Create configuration button
	function LeaPlusLC:CfgBtn(name, parent, tip)
		local CfgBtn = CreateFrame("BUTTON", nil, parent)
		LeaPlusCB[name] = CfgBtn
		CfgBtn:SetWidth(20)
		CfgBtn:SetHeight(20)
		CfgBtn:SetPoint("LEFT", parent.f, "RIGHT", 0, 0)

		CfgBtn.t = CfgBtn:CreateTexture(nil, "BORDER")
		CfgBtn.t:SetAllPoints()
		CfgBtn.t:SetTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn.t:SetTexCoord(0, 0.50, 0, 0.50);
		CfgBtn.t:SetVertexColor(1.0, 0.82, 0, 1.0)

		CfgBtn:SetHighlightTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn:GetHighlightTexture():SetTexCoord(0, 0.50, 0, 0.50);

		CfgBtn.tiptext = tip
		CfgBtn:SetScript("OnEnter", LeaPlusLC.ShowTooltip)
		CfgBtn:SetScript("OnLeave", GameTooltip_Hide)
	end

	-- Capitalise first character in a string
	function LeaPlusLC:CapFirst(str)
		return gsub(string.lower(str), "^%l", strupper)
	end

	-- Toggle Zygor addon
	function LeaPlusLC:ZygorToggle()
		if select(2, GetAddOnInfo("ZygorGuidesViewer")) then
			if not IsAddOnLoaded("ZygorGuidesViewer") then
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					EnableAddOn("ZygorGuidesViewer")
					ReloadUI();
				end
			else
				DisableAddOn("ZygorGuidesViewer")
				ReloadUI();
			end
		else
			-- Zygor cannot be found (no, no, no, no, no, no, no, no!)
			LeaPlusLC:Print("Oh dear!  Cannot seem to find Zygor!\nNo, no, no, no, no, no, no, no!");
			PlaySoundFile("Sound/Creature/Xt002Deconstructor/Ur_Xt002_Special01.Ogg")
		end
		return
	end

	-- Show memory usage stat
	function LeaPlusLC:ShowMemoryUsage(frame, anchor, x, y)
		local ltx = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		ltx:SetPoint(anchor, x, y)
		ltx:SetText("Memory Usage:")

		ltx.stat = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		ltx.stat:SetPoint("LEFT", ltx, "RIGHT")
		ltx.stat:SetText("(calculating...)")

		ltx.time = -1
		frame:SetScript("OnUpdate", function(self, elapsed)
			while (ltx.time > 2 or ltx.time == -1) do
				UpdateAddOnMemoryUsage();
				ltx.text = GetAddOnMemoryUsage("Leatrix_Plus")
				ltx.text = math.floor(ltx.text + .5).. " KB"
				ltx.stat:SetText(ltx.text);
				ltx.time = 0;
			end
			ltx.time = ltx.time + elapsed;
		end)

		-- Release memory
		LeaPlusLC.ShowMemoryUsage = nil

	end

	-- Does character have duel spec
	function LeaPlusLC:IsDualSpec()
		if GetNumSpecGroups() == 2 then
			return true
		else
			return false
		end
	end

	-- Print currently active talent spec
	function LeaPlusLC:ShowActiveSpec()
		if LeaPlusLC:IsDualSpec() then
			local cspec = GetSpecialization();
			if not cspec then return end
			local void, spectree, void, icon, void, role = GetSpecializationInfo(cspec);
			if icon and spectree and role then
				local activespec = GetActiveSpecGroup()
				LeaPlusLC:Print("Your active specialisation is " .. spectree .. " (" .. LeaPlusLC:CapFirst(role) .. ", ".. (activespec == 1 and "Primary" or activespec == 2 and "Secondary").. ").")
			end
		end
	end

	-- Check if player is in LFG queue
	function LeaPlusLC:IsInLFGQueue()
 		if 	GetLFGMode(LE_LFG_CATEGORY_LFD) or
			GetLFGMode(LE_LFG_CATEGORY_LFR) or
			GetLFGMode(LE_LFG_CATEGORY_RF) or
			GetLFGMode(LE_LFG_CATEGORY_SCENARIO) or
			GetLFGMode(LE_LFG_CATEGORY_FLEXRAID) then
			return true
		end
	end

	-- Check if player is in combat
	function LeaPlusLC:PlayerInCombat()
		if (UnitAffectingCombat("player")) then
			LeaPlusLC:Print("You cannot do that in combat.")
			return true
		end
	end

	--  Hide pages
	function LeaPlusLC:HideFrames()

		-- Hide option pages
		for i = 0, LeaPlusLC["NumberOfPages"] do
			if LeaPlusLC["Page"..i] then
				LeaPlusLC["Page"..i]:Hide();
			end;
		end

		-- Hide options panel
		LeaPlusLC["PageF"]:Hide();

	end

	-- Show button tooltips for Leatrix Plus settings
	function LeaPlusLC:ShowTooltip()
		if LeaPlusLC["PlusShowTips"] == "On" then
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			if LeaPlusLC["PanelTipAnchor"] == "On" then
				-- Show tips on the right side of the panel
				GameTooltip:SetPoint("TOPRIGHT",LeaPlusLC["PageF"],"TOPLEFT",0,0)
			else
				-- Show tips on the left side of the panel
				GameTooltip:SetPoint("TOPLEFT",LeaPlusLC["PageF"],"TOPRIGHT",0,0)
			end
			GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
		end
	end

	-- Show button tooltips for interface settings (top side)
	function LeaPlusLC:ShowFacetip()
		if LeaPlusLC["PlusShowTips"] == "On" then
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
		end
	end

	-- Check if a player is in your friends list
	function LeaPlusLC:FriendCheck(name)
		ShowFriends()
		for i = 1, GetNumFriends() do
			if (name == GetFriendInfo(i)) then
				return true
			end
		end
		return false;
	end

	-- Check if a player is in your Real ID friends list
	function LeaPlusLC:RealIDCheck(name)

		-- Get name of inviting character (without realm)
		local invname = strsplit("-", name, 2)
		invname = strtrim(invname)

		-- Update friends list
		ShowFriends()

		-- Traverse friends list for name (does not check realm)
		local numfriends = BNGetNumFriends()
		for i = 1, numfriends do
			local presenceID, void, void, void, toonname, void, client, isOnline = BNGetFriendInfo(i)
			if client == "WoW" and isOnline and toonname then
				if invname == toonname then
					return true
				end
			end
		end
		return false

	end

----------------------------------------------------------------------
--	L04: Load and Save Global Profile
----------------------------------------------------------------------

-- 	Copy globals to locals
	function LeaPlusLC:Load()

		-- Load a string variable or set it to default if it's not set to "On" or "Off"
 		local function LoadVarChk(var, def)
			if not LeaPlusDB[var] then
				-- If variable doesn't exist, set it to default
				LeaPlusDB[var] = def
			else
				-- Variable exists
				if type(LeaPlusDB[var]) == "string" then
					if LeaPlusDB[var] ~= "On" and LeaPlusDB[var] ~= "Off" then
						-- If variable is a string with an invalid value, set it to default
						LeaPlusDB[var] = def
					end
				else
					-- If variable is not a string, set it to default
					LeaPlusDB[var] = def
				end
			end
			-- Set variable to saved value
			LeaPlusLC[var] = LeaPlusDB[var]
		end

		-- Load a numeric variable and set it to default if it's not within a given range
		local function LoadVarNum(var, def, valmin, valmax)
			if not LeaPlusDB[var] then
				-- If variable doesn't exist, set it to default
				LeaPlusDB[var] = def
			else
				-- Variable exists
				if type(LeaPlusDB[var]) == "number" then
					if LeaPlusDB[var] < valmin or LeaPlusDB[var] > valmax then
						-- If variable is a number with an invalid value, set it to default
						LeaPlusDB[var] = def
					end
				else
					-- If variable is not a number, set it to default
					LeaPlusDB[var] = def
				end
			end
			-- Set variable to saved value
			LeaPlusLC[var] = LeaPlusDB[var]
		end

		-- Load an anchor point variable and set it to default if the anchor point is invalid
  		local function LoadVarAnc(var, def)
			if not LeaPlusDB[var] then
				-- If variable doesn't exist, set it to default
				LeaPlusDB[var] = def
			else
				-- Variable exists
				if type(LeaPlusDB[var]) == "string" then
					if LeaPlusDB[var] ~= "CENTER" and LeaPlusDB[var] ~= "TOP" and LeaPlusDB[var] ~= "BOTTOM" and LeaPlusDB[var] ~= "LEFT" and LeaPlusDB[var] ~= "RIGHT" and LeaPlusDB[var] ~= "TOPLEFT" and LeaPlusDB[var] ~= "TOPRIGHT" and LeaPlusDB[var] ~= "BOTTOMLEFT" and LeaPlusDB[var] ~= "BOTTOMRIGHT" then
						-- If variable is a string with an invalid value, set it to default
						LeaPlusDB[var] = def
					end
				else
					-- If variable is not a string, set it to default
					LeaPlusDB[var] = def
				end
			end
			-- Set variable to saved value
			LeaPlusLC[var] = LeaPlusDB[var]
		end

		-- Automation
		LoadVarChk("AcceptPartyFriends", "Off")			-- Party from friends
		LoadVarChk("AcceptPartyGuild", "Off")			-- Party from guild
		LoadVarChk("AutoConfirmRole", "Off")			-- Dungeon groups
		LoadVarChk("InviteFromWhisper", "Off")			-- Invite from whispers
		LeaPlusLC["InvKey"]	= LeaPlusDB["InvKey"] or "plus"
 
		LoadVarChk("AutoReleaseInBG", "Off")			-- Release in battlegrounds
		LoadVarChk("AutoAcceptSummon", "Off")			-- Accept summon
		LoadVarChk("AutoAcceptRes", "Off")				-- Accept resurrect
		LoadVarChk("NoAutoResInCombat", "On")			-- Exclude combat res

		LoadVarChk("NoDuelRequests", "Off")				-- Block duels
		LoadVarChk("NoPetDuels", "Off")					-- Block pet battle duels
		LoadVarChk("NoPartyInvites", "Off")				-- Block party invites

		LoadVarChk("ManageTradeGuild", "Off")			-- Manage blockers
		LoadVarChk("NoTradeRequests", "On")				-- Block trades
		LoadVarChk("NoGuildInvites", "On")				-- Block guild invites

		-- Interaction
		LoadVarChk("AutoSellJunk", "Off")				-- Sell junk automatically
		LoadVarChk("AutoRepairOwnFunds", "Off")			-- Automatically repair
		LoadVarChk("AutoRepairGuildFunds", "On")		-- Use guild funds
		LoadVarChk("NoBagAutomation", "Off")			-- Prevent bag automation
		LoadVarChk("AhExtras", "Off")					-- Auction house extras
		LoadVarChk("AhBuyoutOnly", "Off")				-- Buyout only
		LoadVarChk("AhGoldOnly", "Off")					-- Gold only

		LoadVarChk("NoRaidRestrictions", "Off")			-- Remove raid restrictions
		LoadVarChk("RoleSave", "Off")					-- Save dungeon roles
		LoadVarChk("ShowRaidToggle", "Off")				-- Show raid toggle button

		LoadVarChk("NoConfirmLoot", "Off")				-- Hide loot warnings
		LoadVarChk("NoLootWonAlert", "Off")				-- Hide loot won alerts
		LoadVarChk("SoilAlert", "Off")					-- Dark Soil alert

		-- Chat
		LoadVarChk("UseEasyChatResizing", "Off")		-- Use easy resizing
		LoadVarChk("NoCombatLogTab", "Off")				-- Hide the combat log
		LoadVarChk("NoChatButtons", "Off")				-- Hide chat buttons
		LoadVarChk("UnclampChat", "Off")				-- Unclamp chat frame
		LoadVarChk("MoveChatEditBoxToTop", "Off")		-- Move editbox to top

		LoadVarChk("NoStickyChat", "Off")				-- Disable sticky chat
		LoadVarChk("UseArrowKeysInChat", "Off")			-- Use arrow keys in chat
		LoadVarChk("NoChatFade", "Off")					-- Disable chat fade
		LoadVarChk("MaxChatHstory", "Off")				-- Increase chat history

		LoadVarChk("UnivGroupColor", "Off")				-- Universal group color
		LoadVarChk("Manageclasscolors", "Off")			-- Manage class colors
		LoadVarChk("ColorLocalChannels", "On")			-- Local channel colors
		LoadVarChk("ColorGlobalChannels", "On")			-- Global channel colors

		-- Text
		LoadVarChk("HideZoneText", "Off")				-- Hide zone text
		LoadVarChk("HideSubzoneText", "Off")			-- Hide subzone text

		LoadVarChk("NoHitIndicators", "Off")			-- Hide portrait text

		LoadVarChk("HideErrorFrameText", "Off")			-- Hide error messages
		LoadVarChk("ShowQuestUpdates", "On")			-- Show quest updates

		LoadVarChk("MailFontChange", "Off")				-- Resize mail text
		LoadVarNum("LeaPlusMailFontSize", 22, 10, 36)	-- Mail text slider

		LoadVarChk("QuestFontChange", "Off")			-- Resize quest detail text
		LoadVarNum("LeaPlusQuestFontSize", 18, 10, 36)	-- Quest detail text slider

		-- Interface
		LoadVarChk("ShowMapMod", "Off")					-- Enable world map customisation
		LoadVarChk("MapRevealBox", "On")				-- Map reveal checkbox state

		LoadVarNum("LeaPlusMapScale", 1.0, 0.50, 2.70)	-- Map scale slider
		LoadVarNum("LeaPlusMapOpacity", 0.0, 0.0, 1.0)	-- Map opacity slider

		LoadVarChk("CursorCoords", "On")				-- Show cursor coordinates
		LoadVarChk("MapRing", "Off")					-- Hide player ring
		LoadVarChk("MapLock", "Off")					-- Lock map position
		LoadVarChk("MapQuestBox", "On")					-- Show quest details
		LoadVarChk("MapQuestLeft", "Off")				-- On left side

		LoadVarAnc("MapA", "TOPLEFT")					-- Map anchor
		LoadVarNum("MapX", 10, -5000, 5000)				-- Map position X axis
		LoadVarNum("MapY", -118, -5000, 5000)			-- Map position Y axis

		LoadVarChk("MinimapMod", "Off")					-- Enable minimap customisation
		LoadVarChk("MergeTrackBtn", "Off")				-- Merge buttons
		LoadVarChk("HideMinimapZone", "Off")			-- Hide zone text
		LoadVarChk("HideMinimapTime", "Off")			-- Hide clock
		LoadVarChk("MinimapMouseZoom", "Off")			-- Mousewheel zoom
		LoadVarNum("MinimapScale", 1.00, 0.50, 3.00)	-- Minimap scale slider

		LoadVarChk("FrmEnabled", "Off")					-- Enable frames customisation

		LoadVarChk("ShowVanityButtons", "Off")			-- Show vanity buttons
		LoadVarChk("ShowVanityInFrame", "Off")			-- Vanity buttons dual layout
		LoadVarChk("ShowVolume", "Off")					-- Show volume control
		LoadVarChk("ShowVolumeInFrame", "Off")			-- Volume control dual layout
		LoadVarChk("ShowDressTab", "Off")				-- Show dressup buttons

		LoadVarChk("StaticCoords", "On")				-- Enable coordinates
		LoadVarChk("StaticCoordsEn", "Off")				-- Show coordinates
		LoadVarChk("StaticCoordsBack", "Off")			-- Show background
		LoadVarChk("StaticCoordsTop", "Off")			-- Show on top
		LoadVarChk("StaticCoordsLock", "Off")			-- Lock coordinates
		LoadVarNum("StaticCoordsScale", 2.2, 0.9, 2.2)	-- Coordinates scale slider
		LoadVarAnc("CoordsA", "CENTER")					-- Coordinates anchor
		LoadVarAnc("CoordsR", "CENTER")					-- Coordinates relative
		LoadVarNum("CoordsX", 0, -5000, 5000)			-- Coordinates X axis
		LoadVarNum("CoordsY", 0, -5000, 5000)			-- Coordinates Y axis

		LoadVarChk("ShowSpellIcons", "Off")				-- Show spell icons
		LoadVarChk("ShowSpellTips", "On")				-- Show spell tooltips
		LoadVarChk("SpellIDonTip", "On")				-- Show spell ID in tips
		LoadVarChk("SpellOnPlayer", "Off")				-- Anchor to player

		LoadVarChk("DurabilityStatus", "Off")			-- Show durability status

		-- Miscellaneous
		LoadVarChk("ShowQuestLevels", "Off")			-- Show quest levels
		LoadVarChk("AutoAcceptQuests", "Off")			-- Accept quests
		LoadVarChk("AcceptOnlyDailys", "Off")			-- Restrict to dailies
		LoadVarChk("AutoTurnInQuests", "Off")			-- Turn-in quests
		LoadVarChk("TurnInOnlyDailys", "Off")			-- Restrict to dailies

		LoadVarChk("TipModEnable", "Off")				-- Enable tooltip customisation
		LoadVarChk("TipShowTitle", "On")				-- Show title
		LoadVarChk("TipShowRank", "On")					-- Show rank
		LoadVarChk("TipShowTarget", "On")				-- Show target
		LoadVarChk("TipBackSimple", "Off")				-- Color backdrops
		LoadVarNum("LeaPlusTipSize", 1.00, 0.50, 3.00)	-- Tooltip scale slider

		LoadVarAnc("TipPosAnchor", "BOTTOMRIGHT")		-- Tooltip anchor
		LoadVarAnc("TipPosRelative", "BOTTOMRIGHT")		-- Tooltip relative
		LoadVarNum("TipPosXOffset", -13, -5000, 5000)	-- Tooltip X offset
		LoadVarNum("TipPosYOffset", 94, -5000, 5000)	-- Tooltip Y offset

		LoadVarChk("TipAnchorToMouse", "Off")			-- Anchor to mouse
		LoadVarNum("TipMouseAnchor", 4, 1, 9)			-- Anchor to mouse dropdown value
		LoadVarNum("TipMouseOffsetX", 0, -400, 400)		-- Anchor to mouse X offset
		LoadVarNum("TipMouseOffsetY", -120, -400, 400)	-- Anchor to mouse Y offset
		LoadVarNum("TipAlpha", 1.0, 0, 1.0)				-- Tooltip alpha
		LoadVarChk("TipHideCombat", "Off")				-- Hide tips in combat

		LoadVarChk("NoGryphons", "Off")					-- Hide gryphons
		LoadVarChk("NoClassBar", "Off")					-- Hide stance bar
		LoadVarChk("NoCharControls", "Off")				-- Hide character controls

		LoadVarChk("AutoEnName", "Off")					-- Toggle enemy plates
		LoadVarChk("AutoEnPets", "On")					-- Show pets
		LoadVarChk("AutoEnGuardians", "On")				-- Show guardians
		LoadVarChk("AutoEnTotems", "On")				-- Show totems
		LoadVarChk("AutoEnClassCol", "Off")				-- Show class color

		LoadVarChk("ClassColPlayer", "Off")				-- Player in class color
		LoadVarChk("ClassColTarget", "Off")				-- Target in class color
		LoadVarChk("ShowPlayerChain", "Off")			-- Show player chain
		LoadVarNum("PlayerChainMenu", 2, 1, 3)			-- Player chain dropdown value

		-- System
		LoadVarChk("NoDeathEffect", "Off")				-- Hide death effect
		LoadVarChk("NoSpecialEffects", "Off")			-- Hide special effects
		LoadVarChk("NoGlowEffect", "Off")				-- Remove screen glow
		LoadVarChk("ManageZoomLevel", "Off")			-- Max camera distance

		LoadVarChk("ViewPortEnable", "Off")				-- Enable viewport
		LoadVarNum("ViewPortTop", 0, 0, 250)			-- Top border
		LoadVarNum("ViewPortBottom", 0, 0, 250)			-- Bottom border
		LoadVarNum("ViewPortLeft", 0, 0, 250)			-- Left border
		LoadVarNum("ViewPortRight", 0, 0, 250)			-- Right border
		LoadVarChk("ViewportResize", "Off")				-- Resize game world

		LoadVarChk("ManageRestedEmotes", "Off")			-- Manage emote sounds
		LoadVarChk("NoSoundRested", "On")				-- Silence rested emotes

		LoadVarChk("AchieveControl", "Off")				-- Manage privacy
		LoadVarChk("CharOnlyAchieves", "On")			-- Protect privacy

		LoadVarChk("ManageBnetReq", "Off")				-- Manage friend requests			
		LoadVarChk("BlockBnetReq", "On")				-- Block friend requests

		-- Settings
		LoadVarChk("ShowMinimapIcon", "On")				-- Show minimap button
		LoadVarNum("MinimapIconPos", -65, -180, 180)	-- Minimap button position
		LoadVarChk("ShowStartTag", "On")				-- Show startup message
		LoadVarChk("VersionChecker", "On")				-- Show version warning
		LoadVarChk("OpenPlusAtHome", "Off")				-- Show home on startup
	
		LoadVarChk("PlusShowTips", "On")				-- Show option tooltips
		LoadVarChk("PanelTipAnchor", "Off")				-- On the left side

		LoadVarChk("PlusPanelAlphaCheck", "Off")		-- Modify panel alpha
		LoadVarNum("LeaPlusAlphaValue", 1.0, 0.0, 1.0)	-- Panel alpha slider

		LoadVarChk("PlusPanelScaleCheck", "Off")		-- Modify panel scale
		LoadVarNum("LeaPlusScaleValue", 1.0, 0.0, 1.7)	-- Panel scale slider

		-- Panel position
		LoadVarAnc("MainPanelA", "CENTER")				-- Panel anchor
		LoadVarAnc("MainPanelR", "CENTER")				-- Panel relative
		LoadVarNum("MainPanelX", 0, -5000, 5000)		-- Panel X axis
		LoadVarNum("MainPanelY", 0, -5000, 5000)		-- Panel Y axis

		-- Start page
		LoadVarNum("LeaStartPage", 0, 0, LeaPlusLC["NumberOfPages"])

		-- Save all settings now
		LeaPlusLC:Save();

		-- Release memory
		LeaPlusLC.Load = nil

	end

-- 	Save locals to globals
	function LeaPlusLC:Save()

		-- Automation
		LeaPlusDB["AcceptPartyFriends"]		= LeaPlusLC["AcceptPartyFriends"]
		LeaPlusDB["AcceptPartyGuild"]		= LeaPlusLC["AcceptPartyGuild"]
		LeaPlusDB["AutoConfirmRole"]		= LeaPlusLC["AutoConfirmRole"]
		LeaPlusDB["InviteFromWhisper"]		= LeaPlusLC["InviteFromWhisper"]
		LeaPlusDB["InvKey"]					= LeaPlusLC["InvKey"]

		LeaPlusDB["AutoReleaseInBG"] 		= LeaPlusLC["AutoReleaseInBG"]
		LeaPlusDB["AutoAcceptSummon"] 		= LeaPlusLC["AutoAcceptSummon"]
		LeaPlusDB["AutoAcceptRes"] 			= LeaPlusLC["AutoAcceptRes"]
		LeaPlusDB["NoAutoResInCombat"]		= LeaPlusLC["NoAutoResInCombat"]

		LeaPlusDB["NoDuelRequests"] 		= LeaPlusLC["NoDuelRequests"]
		LeaPlusDB["NoPetDuels"] 			= LeaPlusLC["NoPetDuels"]
		LeaPlusDB["NoPartyInvites"]			= LeaPlusLC["NoPartyInvites"]

		LeaPlusDB["ManageTradeGuild"] 		= LeaPlusLC["ManageTradeGuild"]
		LeaPlusDB["NoTradeRequests"]		= LeaPlusLC["NoTradeRequests"]
		LeaPlusDB["NoGuildInvites"]			= LeaPlusLC["NoGuildInvites"]

		-- Interaction
		LeaPlusDB["AutoSellJunk"] 			= LeaPlusLC["AutoSellJunk"]
		LeaPlusDB["AutoRepairOwnFunds"] 	= LeaPlusLC["AutoRepairOwnFunds"]
		LeaPlusDB["AutoRepairGuildFunds"] 	= LeaPlusLC["AutoRepairGuildFunds"]
		LeaPlusDB["NoBagAutomation"] 		= LeaPlusLC["NoBagAutomation"]
		LeaPlusDB["AhExtras"]				= LeaPlusLC["AhExtras"]
		LeaPlusDB["AhBuyoutOnly"]			= LeaPlusLC["AhBuyoutOnly"]
		LeaPlusDB["AhGoldOnly"]				= LeaPlusLC["AhGoldOnly"]

		LeaPlusDB["NoRaidRestrictions"]		= LeaPlusLC["NoRaidRestrictions"]
		LeaPlusDB["RoleSave"] 				= LeaPlusLC["RoleSave"]
		LeaPlusDB["ShowRaidToggle"]			= LeaPlusLC["ShowRaidToggle"]

		LeaPlusDB["NoConfirmLoot"] 			= LeaPlusLC["NoConfirmLoot"]
		LeaPlusDB["NoLootWonAlert"] 		= LeaPlusLC["NoLootWonAlert"]
		LeaPlusDB["SoilAlert"] 				= LeaPlusLC["SoilAlert"]

		-- Chat
		LeaPlusDB["UseEasyChatResizing"]	= LeaPlusLC["UseEasyChatResizing"]
		LeaPlusDB["NoCombatLogTab"]			= LeaPlusLC["NoCombatLogTab"]
		LeaPlusDB["NoChatButtons"]			= LeaPlusLC["NoChatButtons"]
		LeaPlusDB["UnclampChat"]			= LeaPlusLC["UnclampChat"]
		LeaPlusDB["MoveChatEditBoxToTop"]	= LeaPlusLC["MoveChatEditBoxToTop"]

		LeaPlusDB["NoStickyChat"] 			= LeaPlusLC["NoStickyChat"]
		LeaPlusDB["UseArrowKeysInChat"]		= LeaPlusLC["UseArrowKeysInChat"]
		LeaPlusDB["NoChatFade"]				= LeaPlusLC["NoChatFade"]
		LeaPlusDB["MaxChatHstory"]			= LeaPlusLC["MaxChatHstory"]

		LeaPlusDB["UnivGroupColor"]			= LeaPlusLC["UnivGroupColor"]
		LeaPlusDB["Manageclasscolors"]		= LeaPlusLC["Manageclasscolors"]
		LeaPlusDB["ColorLocalChannels"]		= LeaPlusLC["ColorLocalChannels"]
		LeaPlusDB["ColorGlobalChannels"]	= LeaPlusLC["ColorGlobalChannels"]

		-- Text
		LeaPlusDB["HideZoneText"] 			= LeaPlusLC["HideZoneText"]
		LeaPlusDB["HideSubzoneText"] 		= LeaPlusLC["HideSubzoneText"]

		LeaPlusDB["NoHitIndicators"]		= LeaPlusLC["NoHitIndicators"]

		LeaPlusDB["HideErrorFrameText"]		= LeaPlusLC["HideErrorFrameText"]
		LeaPlusDB["ShowQuestUpdates"]		= LeaPlusLC["ShowQuestUpdates"]

		LeaPlusDB["MailFontChange"] 		= LeaPlusLC["MailFontChange"]
		LeaPlusDB["LeaPlusMailFontSize"] 	= LeaPlusLC["LeaPlusMailFontSize"]

		LeaPlusDB["QuestFontChange"] 		= LeaPlusLC["QuestFontChange"]
		LeaPlusDB["LeaPlusQuestFontSize"]	= LeaPlusLC["LeaPlusQuestFontSize"]

		-- Interface
		LeaPlusDB["ShowMapMod"] 			= LeaPlusLC["ShowMapMod"]
		LeaPlusDB["MapRevealBox"] 			= LeaPlusLC["MapRevealBox"]
		LeaPlusDB["LeaPlusMapScale"] 		= LeaPlusLC["LeaPlusMapScale"]
		LeaPlusDB["LeaPlusMapOpacity"] 		= LeaPlusLC["LeaPlusMapOpacity"]
		LeaPlusDB["CursorCoords"] 			= LeaPlusLC["CursorCoords"]
		LeaPlusDB["MapRing"] 				= LeaPlusLC["MapRing"]
		LeaPlusDB["MapLock"] 				= LeaPlusLC["MapLock"]
		LeaPlusDB["MapQuestBox"] 			= LeaPlusLC["MapQuestBox"]
		LeaPlusDB["MapQuestLeft"] 			= LeaPlusLC["MapQuestLeft"]
		LeaPlusDB["MapA"] 					= LeaPlusLC["MapA"]
		LeaPlusDB["MapX"] 					= LeaPlusLC["MapX"]
		LeaPlusDB["MapY"] 					= LeaPlusLC["MapY"]

		LeaPlusDB["MinimapMod"]				= LeaPlusLC["MinimapMod"]
		LeaPlusDB["MergeTrackBtn"]			= LeaPlusLC["MergeTrackBtn"]
		LeaPlusDB["HideMinimapZone"]		= LeaPlusLC["HideMinimapZone"]
		LeaPlusDB["HideMinimapTime"]		= LeaPlusLC["HideMinimapTime"]
		LeaPlusDB["MinimapMouseZoom"]		= LeaPlusLC["MinimapMouseZoom"]
		LeaPlusDB["MinimapScale"]			= LeaPlusLC["MinimapScale"]

		LeaPlusDB["FrmEnabled"]				= LeaPlusLC["FrmEnabled"]

		LeaPlusDB["ShowVanityButtons"]		= LeaPlusLC["ShowVanityButtons"]
		LeaPlusDB["ShowVanityInFrame"]		= LeaPlusLC["ShowVanityInFrame"]
		LeaPlusDB["ShowVolume"] 			= LeaPlusLC["ShowVolume"]
		LeaPlusDB["ShowVolumeInFrame"] 		= LeaPlusLC["ShowVolumeInFrame"]
		LeaPlusDB["ShowDressTab"] 			= LeaPlusLC["ShowDressTab"]

		LeaPlusDB["StaticCoords"] 			= LeaPlusLC["StaticCoords"]
		LeaPlusDB["CoordsA"] 				= LeaPlusLC["CoordsA"]
		LeaPlusDB["CoordsR"] 				= LeaPlusLC["CoordsR"]
		LeaPlusDB["CoordsX"] 				= LeaPlusLC["CoordsX"]
		LeaPlusDB["CoordsY"] 				= LeaPlusLC["CoordsY"]
		LeaPlusDB["StaticCoordsEn"] 		= LeaPlusLC["StaticCoordsEn"]
		LeaPlusDB["StaticCoordsBack"] 		= LeaPlusLC["StaticCoordsBack"]
		LeaPlusDB["StaticCoordsScale"] 		= LeaPlusLC["StaticCoordsScale"]
		LeaPlusDB["StaticCoordsLock"] 		= LeaPlusLC["StaticCoordsLock"]
		LeaPlusDB["StaticCoordsTop"] 		= LeaPlusLC["StaticCoordsTop"]

		LeaPlusDB["ShowSpellIcons"]			= LeaPlusLC["ShowSpellIcons"]
		LeaPlusDB["ShowSpellTips"]			= LeaPlusLC["ShowSpellTips"]
		LeaPlusDB["SpellIDonTip"]			= LeaPlusLC["SpellIDonTip"]
		LeaPlusDB["SpellOnPlayer"]			= LeaPlusLC["SpellOnPlayer"]

		LeaPlusDB["DurabilityStatus"]		= LeaPlusLC["DurabilityStatus"]

		-- Miscellaneous
		LeaPlusDB["ShowQuestLevels"]		= LeaPlusLC["ShowQuestLevels"]
		LeaPlusDB["AutoAcceptQuests"] 		= LeaPlusLC["AutoAcceptQuests"]
		LeaPlusDB["AcceptOnlyDailys"] 		= LeaPlusLC["AcceptOnlyDailys"]
		LeaPlusDB["AutoTurnInQuests"] 		= LeaPlusLC["AutoTurnInQuests"]
		LeaPlusDB["TurnInOnlyDailys"] 		= LeaPlusLC["TurnInOnlyDailys"]

		LeaPlusDB["TipModEnable"]			= LeaPlusLC["TipModEnable"]
		LeaPlusDB["TipShowTitle"]			= LeaPlusLC["TipShowTitle"]
		LeaPlusDB["TipShowRank"]			= LeaPlusLC["TipShowRank"]
		LeaPlusDB["TipShowTarget"]			= LeaPlusLC["TipShowTarget"]
		LeaPlusDB["TipBackSimple"]			= LeaPlusLC["TipBackSimple"]
		LeaPlusDB["LeaPlusTipSize"]			= LeaPlusLC["LeaPlusTipSize"]
		LeaPlusDB["TipPosAnchor"]			= LeaPlusLC["TipPosAnchor"]
		LeaPlusDB["TipPosRelative"]			= LeaPlusLC["TipPosRelative"]
		LeaPlusDB["TipPosXOffset"]			= LeaPlusLC["TipPosXOffset"]
		LeaPlusDB["TipPosYOffset"]			= LeaPlusLC["TipPosYOffset"]
		LeaPlusDB["TipAnchorToMouse"]		= LeaPlusLC["TipAnchorToMouse"]
		LeaPlusDB["TipMouseAnchor"]			= LeaPlusLC["TipMouseAnchor"]
		LeaPlusDB["TipMouseOffsetX"]		= LeaPlusLC["TipMouseOffsetX"]
		LeaPlusDB["TipMouseOffsetY"]		= LeaPlusLC["TipMouseOffsetY"]
		LeaPlusDB["TipAlpha"]				= LeaPlusLC["TipAlpha"]
		LeaPlusDB["TipHideCombat"]			= LeaPlusLC["TipHideCombat"]

		LeaPlusDB["NoGryphons"]				= LeaPlusLC["NoGryphons"]
		LeaPlusDB["NoClassBar"]				= LeaPlusLC["NoClassBar"]
		LeaPlusDB["NoCharControls"]			= LeaPlusLC["NoCharControls"]

		LeaPlusDB["AutoEnName"]				= LeaPlusLC["AutoEnName"]
		LeaPlusDB["AutoEnPets"]				= LeaPlusLC["AutoEnPets"]
		LeaPlusDB["AutoEnGuardians"]		= LeaPlusLC["AutoEnGuardians"]
		LeaPlusDB["AutoEnTotems"]			= LeaPlusLC["AutoEnTotems"]
		LeaPlusDB["AutoEnClassCol"]			= LeaPlusLC["AutoEnClassCol"]

		LeaPlusDB["ClassColPlayer"]			= LeaPlusLC["ClassColPlayer"]
		LeaPlusDB["ClassColTarget"]			= LeaPlusLC["ClassColTarget"]
		LeaPlusDB["ShowPlayerChain"]		= LeaPlusLC["ShowPlayerChain"]
		LeaPlusDB["PlayerChainMenu"]		= LeaPlusLC["PlayerChainMenu"]

		-- System
		LeaPlusDB["NoDeathEffect"] 			= LeaPlusLC["NoDeathEffect"]
		LeaPlusDB["NoSpecialEffects"] 		= LeaPlusLC["NoSpecialEffects"]
		LeaPlusDB["NoGlowEffect"] 			= LeaPlusLC["NoGlowEffect"]
		LeaPlusDB["ManageZoomLevel"]		= LeaPlusLC["ManageZoomLevel"]

		LeaPlusDB["ViewPortEnable"]			= LeaPlusLC["ViewPortEnable"]
		LeaPlusDB["ViewportResize"]			= LeaPlusLC["ViewportResize"]
		LeaPlusDB["ViewPortTop"]			= LeaPlusLC["ViewPortTop"]
		LeaPlusDB["ViewPortBottom"]			= LeaPlusLC["ViewPortBottom"]
		LeaPlusDB["ViewPortLeft"]			= LeaPlusLC["ViewPortLeft"]
		LeaPlusDB["ViewPortRight"]			= LeaPlusLC["ViewPortRight"]

		LeaPlusDB["ManageRestedEmotes"]		= LeaPlusLC["ManageRestedEmotes"]
		LeaPlusDB["NoSoundRested"]			= LeaPlusLC["NoSoundRested"]

		LeaPlusDB["AchieveControl"]			= LeaPlusLC["AchieveControl"]
		LeaPlusDB["CharOnlyAchieves"]		= LeaPlusLC["CharOnlyAchieves"]

		LeaPlusDB["ManageBnetReq"]			= LeaPlusLC["ManageBnetReq"]
		LeaPlusDB["BlockBnetReq"]			= LeaPlusLC["BlockBnetReq"]

		-- Settings
		LeaPlusDB["ShowMinimapIcon"] 		= LeaPlusLC["ShowMinimapIcon"]
		LeaPlusDB["MinimapIconPos"] 		= LeaPlusLC["MinimapIconPos"]
		LeaPlusDB["ShowStartTag"]			= LeaPlusLC["ShowStartTag"]
		LeaPlusDB["VersionChecker"]			= LeaPlusLC["VersionChecker"]
		LeaPlusDB["OpenPlusAtHome"]			= LeaPlusLC["OpenPlusAtHome"]

		LeaPlusDB["PlusShowTips"] 			= LeaPlusLC["PlusShowTips"]
		LeaPlusDB["PanelTipAnchor"] 		= LeaPlusLC["PanelTipAnchor"]

		LeaPlusDB["PlusPanelAlphaCheck"] 	= LeaPlusLC["PlusPanelAlphaCheck"]
		LeaPlusDB["LeaPlusAlphaValue"] 		= LeaPlusLC["LeaPlusAlphaValue"]

		LeaPlusDB["PlusPanelScaleCheck"] 	= LeaPlusLC["PlusPanelScaleCheck"]
		LeaPlusDB["LeaPlusScaleValue"] 		= LeaPlusLC["LeaPlusScaleValue"]

		-- Start page
		LeaPlusDB["LeaStartPage"]			= LeaPlusLC["LeaStartPage"]

		-- Panel position
		LeaPlusDB["MainPanelA"]				= LeaPlusLC["MainPanelA"]
		LeaPlusDB["MainPanelR"]				= LeaPlusLC["MainPanelR"]
		LeaPlusDB["MainPanelX"]				= LeaPlusLC["MainPanelX"]
		LeaPlusDB["MainPanelY"]				= LeaPlusLC["MainPanelY"]

	end

----------------------------------------------------------------------
--	L20: Live
----------------------------------------------------------------------

--	The Live bit
	function LeaPlusLC:Live()

		----------------------------------------------------------------------
		--	Automatically accept Dungeon Finder queue requests
		----------------------------------------------------------------------

		if LeaPlusLC["AutoConfirmRole"] == "On" then
			LFDRoleCheckPopupAcceptButton:SetScript("OnShow", function()
				local leader = ""
				for i=1, GetNumSubgroupMembers() do 
					if (UnitIsGroupLeader("party"..i)) then 
						leader = UnitName("party"..i);
						break;
					end
				end
				if (LeaPlusLC:FriendCheck(leader)) or (LeaPlusLC:RealIDCheck(leader)) then
					LFDRoleCheckPopupAcceptButton:Click();
				end
			end)
		else
			LFDRoleCheckPopupAcceptButton:SetScript("OnShow", nil)
		end

		----------------------------------------------------------------------
		--	Invite from whispers
		----------------------------------------------------------------------

		if LeaPlusLC["InviteFromWhisper"] == "On" then
			LpEvt:RegisterEvent("CHAT_MSG_WHISPER");
			LpEvt:RegisterEvent("CHAT_MSG_BN_WHISPER");
		else
			LpEvt:UnregisterEvent("CHAT_MSG_WHISPER");
			LpEvt:UnregisterEvent("CHAT_MSG_BN_WHISPER");
		end

		----------------------------------------------------------------------
		--	Disable full-screen glow
		----------------------------------------------------------------------

		if LeaPlusLC["NoGlowEffect"] == "On" then
			SetCVar("ffxGlow", "0")
		else
			SetCVar("ffxGlow", "1")
		end

		----------------------------------------------------------------------
		--	Disable death effect
		----------------------------------------------------------------------

		if LeaPlusLC["NoDeathEffect"] == "On" then
			SetCVar("ffxDeath", "0")
		else
			SetCVar("ffxDeath", "1")
		end

		----------------------------------------------------------------------
		--	Disable special effects
		----------------------------------------------------------------------

		if LeaPlusLC["NoSpecialEffects"] == "On" then
			SetCVar("ffxSpecial", "0")
			SetCVar("ffxNetherWorld", "0")
		else
			SetCVar("ffxSpecial", "1")
			SetCVar("ffxNetherWorld", "1")
		end

		----------------------------------------------------------------------
		--	Block duels
		----------------------------------------------------------------------

		if LeaPlusLC["NoDuelRequests"] == "On" then
			LpEvt:RegisterEvent("DUEL_REQUESTED");
		else
			LpEvt:UnregisterEvent("DUEL_REQUESTED");
		end

		----------------------------------------------------------------------
		--	Block pet battle duels
		----------------------------------------------------------------------

		if LeaPlusLC["NoPetDuels"] == "On" then
			LpEvt:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED");
		else
			LpEvt:UnregisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED");
		end

		----------------------------------------------------------------------
		--	Block party invites
		----------------------------------------------------------------------

		if LeaPlusLC["NoPartyInvites"] == "On" or LeaPlusLC["AcceptPartyFriends"] == "On" then
			LpEvt:RegisterEvent("PARTY_INVITE_REQUEST");
		else
			LpEvt:UnregisterEvent("PARTY_INVITE_REQUEST");
		end

		----------------------------------------------------------------------
		--	Battleground release
		----------------------------------------------------------------------

		if LeaPlusLC["AutoReleaseInBG"] == "On" then
			LpEvt:RegisterEvent("PLAYER_DEAD");
		else
			LpEvt:UnregisterEvent("PLAYER_DEAD");
		end

		----------------------------------------------------------------------
		--	Automatic resurrection
		----------------------------------------------------------------------

		if LeaPlusLC["AutoAcceptRes"] == "On" then
			LpEvt:RegisterEvent("RESURRECT_REQUEST");
		else
			LpEvt:UnregisterEvent("RESURRECT_REQUEST");
		end

		----------------------------------------------------------------------
		--	Automatic summon
		----------------------------------------------------------------------

		if LeaPlusLC["AutoAcceptSummon"] == "On" then
			LpEvt:RegisterEvent("CONFIRM_SUMMON");
		else
			LpEvt:UnregisterEvent("CONFIRM_SUMMON");
		end

		----------------------------------------------------------------------
		--	Automatically accept quests
		----------------------------------------------------------------------

		if LeaPlusLC["AutoAcceptQuests"] == "On" or (LeaPlusLC["AutoAcceptQuests"] == "On" and LeaPlusLC["AcceptOnlyDailys"] == "On") then
			LpEvt:RegisterEvent("QUEST_DETAIL");
			LpEvt:RegisterEvent("QUEST_ACCEPT_CONFIRM")
		else
			LpEvt:UnregisterEvent("QUEST_DETAIL");
			LpEvt:UnregisterEvent("QUEST_ACCEPT_CONFIRM")
		end

		----------------------------------------------------------------------
		--	Automatically turn-in quests
		----------------------------------------------------------------------

		if LeaPlusLC["AutoTurnInQuests"] == "On" then
			LpEvt:RegisterEvent("QUEST_PROGRESS")
			LpEvt:RegisterEvent("QUEST_COMPLETE")
		else
			LpEvt:UnregisterEvent("QUEST_PROGRESS")
			LpEvt:UnregisterEvent("QUEST_COMPLETE")
		end

		----------------------------------------------------------------------
		--	Sell junk automatically and repair automatically
		----------------------------------------------------------------------

		if LeaPlusLC["AutoSellJunk"] == "On" or LeaPlusLC["AutoRepairOwnFunds"] == "On" then
			LpEvt:RegisterEvent("MERCHANT_SHOW");
		else
			LpEvt:UnregisterEvent("MERCHANT_SHOW");
		end

		----------------------------------------------------------------------
		--	Don't confirm loot rolls
		----------------------------------------------------------------------

		if LeaPlusLC["NoConfirmLoot"] == "On" then
			LpEvt:RegisterEvent("CONFIRM_LOOT_ROLL");
			LpEvt:RegisterEvent("CONFIRM_DISENCHANT_ROLL");
			LpEvt:RegisterEvent("LOOT_BIND_CONFIRM")
		else
			LpEvt:UnregisterEvent("CONFIRM_LOOT_ROLL");
			LpEvt:UnregisterEvent("CONFIRM_DISENCHANT_ROLL");
			LpEvt:UnregisterEvent("LOOT_BIND_CONFIRM");
		end

	end

----------------------------------------------------------------------
--	L30: Isolated code
----------------------------------------------------------------------

	function LeaPlusLC:Isolated()

		----------------------------------------------------------------------
		-- Show warning if using a very old version of Leatrix Plus
		----------------------------------------------------------------------

		if LeaPlusLC["VersionChecker"] == "On" then

			local wowversion = select(4, GetBuildInfo()) or 0;
			local plusversion = tonumber(LeaPlusLC["InterfaceVer"]);

			if plusversion < wowversion then

				-- Create the background panel
				local Panel = CreateFrame("Frame", nil, UIParent);
				LeaPlusLC["VersionPanel"] = Panel;
				Panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0); 
				Panel:SetSize(440, 220);
				Panel:SetFrameStrata("FULLSCREEN_DIALOG"); 
				Panel:SetToplevel(true);
				Panel:SetScale(1.3);
				Panel:SetClampedToScreen(true);

				-- Allow the panel to be moved
				Panel:EnableMouse(true);
				Panel:SetMovable(true);
				Panel:RegisterForDrag("LeftButton");
				Panel:SetScript("OnDragStart", Panel.StartMoving);
				Panel:SetScript("OnDragStop", Panel.StopMovingOrSizing);

				-- Add background color
				Panel.t = Panel:CreateTexture(Panel, "BACKGROUND");
				Panel.t:SetAllPoints();
				Panel.t:SetTexture(0.05, 0.05, 0.05, 0.9);

				-- Add textures
				Panel.x = Panel:CreateTexture(nil, "BORDER")
				Panel.x:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
				Panel.x:SetSize(440, 220)  
				Panel.x:SetPoint("TOPRIGHT")
				Panel.x:SetVertexColor(0.7, 0.7, 0.7, 0.7)

				-- Add close Button
				local CloseB = CreateFrame("Button", nil, Panel, "UIPanelCloseButton");
				CloseB:SetSize(30, 30);
				CloseB:SetPoint("TOPRIGHT", 0, 0);
				CloseB:SetScript("OnClick", function() 
					Panel:Hide();
				end);

				LeaPlusLC:MakeTx(Panel, "Version Warning", 16, -10);
				LeaPlusLC:MakeWD(Panel, "This version of Leatrix Plus was designed for an older World", 16, -30);
				LeaPlusLC:MakeWD(Panel, "of Warcraft content patch.  To maintain performance and", 16, -50);
				LeaPlusLC:MakeWD(Panel, "stability, please update it immediately.", 16, -70);

				LeaPlusLC:MakeTx(Panel, "Resolution", 16, -110);
				LeaPlusLC:MakeWD(Panel, "Download the latest version from |cff00FF96www.leatrix.com|r.", 16, -130);

				LeaPlusLC:MakeTx(Panel, "Leatrix Plus", 16, -170);
				LeaPlusLC:MakeWD(Panel, plusversion, 16, -190);

				LeaPlusLC:MakeTx(Panel, "World of Warcraft", 146, -170);
				LeaPlusLC:MakeWD(Panel, wowversion, 146, -190);

				local VerBtn = LeaPlusLC:CreateButton("ClearVerWarn", Panel, "Ok", "BOTTOMRIGHT", -10, 10, 70, 25, true, "");
				VerBtn:SetScript("OnClick", function() Panel:Hide() end)

				-- Texture the button
				local function SetBtn()
					VerBtn.Left:SetTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus_Up.blp")
					VerBtn.Middle:SetTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus_Up.blp")
					VerBtn.Right:SetTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus_Up.blp")
					VerBtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus_High.blp")
				end

				VerBtn:HookScript("OnShow", SetBtn)
				VerBtn:HookScript("OnMouseDown", SetBtn)
				VerBtn:HookScript("OnMouseUp", SetBtn)
				SetBtn()

			end

		end

		----------------------------------------------------------------------
		-- Chat style
		----------------------------------------------------------------------

		-- Set the chat style to classic and prevent changes (since IM mode is bugged)
		SetCVar("chatStyle", "classic")
		InterfaceOptionsSocialPanelChatStyleButton:Disable()
		InterfaceOptionsSocialPanelChatStyleText:SetAlpha(0.7)

		----------------------------------------------------------------------
		--	Show player chain
		----------------------------------------------------------------------

		if LeaPlusDB["ShowPlayerChain"] == "On" then -- Checks global

			-- Create configuration panel
			local ChainPanel = LeaPlusLC:CreateSidePanel("Player Chain", 164, 160)

			-- Add dropdown menu
			LeaPlusLC:CreateDropDown("PlayerChainMenu", "Style", ChainPanel, 146, "TOPLEFT", 10, -100, {"RARE", "ELITE", "RARE ELITE"}, "")

			-- Set chain style
			local function SetChainStyle()
				-- Get dropdown menu valie
				local chain = LeaPlusLC["PlayerChainMenu"] -- Numeric value
				-- Set chain style according to value
				if chain == 1 then -- Rare
					PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare.blp");
				elseif chain == 2 then -- Elite
					PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite.blp");
				elseif chain == 3 then -- Rare Elite
					PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite.blp");
				end
			end

			-- Set style on startup
			SetChainStyle()

			-- Set style when a drop menu is selected (procs when the list is hidden)
			LeaPlusCB["ListFramePlayerChainMenu"]:HookScript("OnHide", function()
				SetChainStyle()
			end)

			-- Create save button
			LeaPlusLC:CreateButton("SavePlayerChainBtn", ChainPanel, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
			LeaPlusCB["SavePlayerChainBtn"]:SetScript("OnClick", function()
				LeaPlusCB["ListFramePlayerChainMenu"]:Hide(); -- Hide the dropdown list
				ChainPanel:Hide();
				LeaPlusLC["PageF"]:Show();
				LeaPlusLC["Page6"]:Show();
				return
			end)

			-- Create reset button
			LeaPlusLC:CreateButton("ResetPlayerChainBtn", ChainPanel, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
			LeaPlusCB["ResetPlayerChainBtn"]:SetScript("OnClick", function()
				LeaPlusCB["ListFramePlayerChainMenu"]:Hide(); -- Hide the dropdown list
				LeaPlusLC["PlayerChainMenu"] = 2
				ChainPanel:Hide(); ChainPanel:Show();
				SetChainStyle()
			end)

			-- Show the panel when the configuration button is clicked
			LeaPlusCB["ModPlayerChain"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					LeaPlusLC["PlayerChainMenu"] = 3;
					SetChainStyle();
				else
					LeaPlusLC:HideFrames();
					ChainPanel:Show();
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show raid frame toggle button
		----------------------------------------------------------------------

		if LeaPlusLC["ShowRaidToggle"] == "On" then

			-- Check to make sure raid toggle button exists
			if CompactRaidFrameManagerDisplayFrameHiddenModeToggle then

				-- Create a border for the button
				CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetBackdrop({ 
					edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
					tile = false, tileSize = 0, edgeSize = 16,
					insets = { left = 0, right = 0, top = 0, bottom = 0 }})

				-- Move the button (function runs after PLAYER_ENTERING_WORLD and PARTY_LEADER_CHANGED)
				hooksecurefunc("CompactRaidFrameManager_UpdateOptionsFlowContainer", function()
					if CompactRaidFrameManager and CompactRaidFrameManagerDisplayFrameHiddenModeToggle then
						local void, void, void, void, y = CompactRaidFrameManager:GetPoint()
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetWidth(40)
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:ClearAllPoints()
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, y + 22)
						CompactRaidFrameManagerDisplayFrameHiddenModeToggle:SetParent(UIParent)
					end
				end)

			end

		end

		----------------------------------------------------------------------
		-- Hide hit indicators (portrait text)
		----------------------------------------------------------------------

		if LeaPlusLC["NoHitIndicators"] == "On" then
			hooksecurefunc(PlayerHitIndicator, "Show", PlayerHitIndicator.Hide)
			hooksecurefunc(PetHitIndicator, "Show", PetHitIndicator.Hide)
		end

		----------------------------------------------------------------------
		-- Class colored player
		----------------------------------------------------------------------

		if LeaPlusLC["ClassColPlayer"] == "On" then

			local PlayFN = CreateFrame("FRAME", nil, PlayerFrame)
			PlayFN:SetWidth(119)
			PlayFN:SetHeight(19)
			PlayFN:SetPoint("TOPLEFT", "PlayerFrame", "TOPLEFT", 106, -22)

			PlayFN.t = PlayFN:CreateTexture(nil, "BORDER")
			PlayFN.t:SetAllPoints()
			PlayFN.t:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")

			local c = LeaPlusLC["RaidColors"][select(2, UnitClass("player"))]
			PlayFN.t:SetVertexColor(c.r, c.g, c.b)

		end

		----------------------------------------------------------------------
		-- Class colored target
		----------------------------------------------------------------------

		if LeaPlusLC["ClassColTarget"] == "On" then

			local function TargetFrameCol()
				if UnitIsPlayer("target") then
					local c = LeaPlusLC["RaidColors"][select(2, UnitClass("target"))]
					TargetFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
				end
		
				if UnitIsPlayer("focus") then
					local c = LeaPlusLC["RaidColors"][select(2, UnitClass("focus"))]
					FocusFrameNameBackground:SetVertexColor(c.r, c.g, c.b)
				end
			end

			local ColTar = CreateFrame("FRAME")
			ColTar:RegisterEvent("GROUP_ROSTER_UPDATE")
			ColTar:RegisterEvent("PLAYER_TARGET_CHANGED")
			ColTar:RegisterEvent("PLAYER_FOCUS_CHANGED")
			ColTar:RegisterEvent("UNIT_FACTION")
			ColTar:SetScript("OnEvent", TargetFrameCol)

			-- Refresh color if focus frame size changes
			hooksecurefunc("FocusFrame_SetSmallSize", TargetFrameCol)

		end

		----------------------------------------------------------------------
		-- Show spell icons
		----------------------------------------------------------------------

		-- Show spell icons
		if LeaPlusLC["ShowSpellIcons"] == "On" then

			-- Disable buffs on top of target frame (otherwise they would conflict)
			TargetFrame_UpdateBuffsOnTop = function() TARGET_FRAME_BUFFS_ON_TOP = false; end

			-- Create local tables to store spell icons and editboxes
			local icon = {}; -- Used to store spell icon frames
			local SpellEB = {}; -- Used to store editbox values
			local iCount = 5; -- Number of spell icons

			-- Create spell icon frames
			for i = 1, iCount do

				-- Create spell icon frame
				icon[i] = CreateFrame("Frame", nil, UIParent)
				icon[i]:SetFrameStrata("BACKGROUND")
				icon[i]:SetWidth(20)
				icon[i]:SetHeight(20)

				-- Create cooldown icon
				icon[i].c = CreateFrame("Cooldown", nil, icon[i], "CooldownFrameTemplate")
				icon[i].c:SetAllPoints();
				icon[i].c:SetReverse(true)

				-- Create texture (will be overwritten with spell texture later)
				icon[i].t = icon[i]:CreateTexture(nil,"BACKGROUND")
				icon[i].t:SetAllPoints()

				-- Create frame for OnUpdate to anchor to (so it doesn't need to run unnecessarily)
				icon[i].z = CreateFrame("Frame", nil, icon[i])
				icon[i].z:Hide();

			end

			-- Change spell icon scale when player frame scale changes
			PlayerFrame:HookScript("OnSizeChanged", function(self, name, value)
				if LeaPlusLC["SpellOnPlayer"] == "On" then
					for i = 1, iCount do
						icon[i]:SetScale(PlayerFrame:GetScale());
					end
				end
			end)

			-- Change spell icon scale when target frame scale changes
			TargetFrame:HookScript("OnSizeChanged", function(self, name, value)
				if LeaPlusLC["SpellOnPlayer"] == "Off" then
					for i = 1, iCount do
						icon[i]:SetScale(TargetFrame:GetScale());
					end
				end
			end)

			-- Function to set spell cooldowns to the icons
			local function ShowIcon(i, id, owner)

				local void

				-- Get spell information
				local spell, void, path = GetSpellInfo(id)

				if spell and path then

					-- Set icon texture to the spell texture
					icon[i].t:SetTexture(path)

					-- Set top level (ensures tooltips show properly)
					icon[i]:SetToplevel(true)

					-- Update icon tooltip
					if LeaPlusLC["ShowSpellTips"] == "On" then

						-- Update tooltip while OnEnter is active
						icon[i].z:SetScript("OnUpdate", function()
							if (GameTooltip:IsOwned(icon[i])) then
								-- Tooltip is showing so update it
								GameTooltip:SetUnitBuff(owner, spell);
							end
						end)

						-- Show tooltip when OnEnter is active
						icon[i]:SetScript("OnEnter", function(self)
							if LeaPlusLC["ShowSpellTips"] == "On" then
								-- Show the tooltip for the spell
								GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 15, -25)
								GameTooltip:SetUnitBuff(owner, spell);
								-- Show the anchor frame to trigger OnUpdate
								icon[i].z:Show();
							end
						end)

						-- Hide tooltip and remove OnUpdate
						icon[i]:SetScript("OnLeave", function(self)
							if LeaPlusLC["ShowSpellTips"] == "On" then
								GameTooltip:Hide();
								-- Hide the anchor frame
								icon[i].z:Hide();
							end
						end)

					else

						-- Clear all script handlers if tooltips aren't required
						icon[i].z:SetScript("OnUpdate", nil);
						icon[i]:SetScript("OnEnter", nil);
						icon[i]:SetScript("OnLeave", nil);

					end
					
					-- Handle events
					icon[i]:RegisterUnitEvent("UNIT_AURA", owner)
					icon[i]:RegisterUnitEvent("UNIT_PET", "player")
					icon[i]:SetScript("OnEvent", function(self, event, arg1)

						-- If pet was dismissed (or otherwise disappears such as when flying), hide pet spell icons
						if event == "UNIT_PET" then
							if not UnitExists("pet") then
								if LeaPlusDC["Spell"..i.."Pet"] then
									icon[i]:Hide();
								end
							end

						-- Ensure spell belongs to the owner we're watching (player or pet)
						elseif arg1 == owner then

							-- Hide the icon frame (required for icons to disappear after the duration)
							icon[i]:Hide()

							-- If buff matches spell we want, start the cooldown
							local buff, void, void, stack, void, length, expire = UnitBuff(owner, spell)
							if buff then
								local stackval = tonumber(SpellEB[i.."Stack"]:GetText())
								if (stackval and stack >= stackval) or (not stackval) then
									icon[i]:Show();
									local start = expire - length
									CooldownFrame_SetTimer(icon[i].c, start, length, 1)
								end
							end

						end
					end)

				else

					-- Spell does not exist so no point in watching it
					icon[i]:UnregisterEvent("UNIT_AURA")
					icon[i]:SetScript("OnEvent", nil);
					icon[i]:Hide();
					icon[i].z:SetScript("OnUpdate", nil);
					icon[i]:SetScript("OnEnter", nil);
					icon[i]:SetScript("OnLeave", nil);

				end

			end

			-- Create side panel
			local SpellPanel = LeaPlusLC:CreateSidePanel("Spell Icons", 164, 380)

			-- Function to refresh the tooltip with the spell name
			local function RefSpellTip(self,elapsed)
				local spellinfo, void, icon = GetSpellInfo(self:GetText());
				if spellinfo and icon then
					GameTooltip:SetOwner(self, "ANCHOR_LEFT", -10, -26)
					GameTooltip:SetText("|T" .. icon .. ":0|t " .. spellinfo, nil, nil, nil, nil, true)
				else
					GameTooltip:Hide();
				end
			end

			-- Function to create spell ID editboxes and pet checkboxes
			local function MakeSpellEB(num, x, y, tab, shifttab)

				-- Create editbox for spell ID
				SpellEB[num] = LeaPlusLC:CreateEditBox("SpellEB" .. num, SpellPanel, 70, 6, "TOPLEFT", x, y-20, "SpellEB" .. num .. "Stack", "SpellEB" .. shifttab .. "Stack");
				SpellEB[num]:SetNumeric(true);

				-- Refresh tooltip when mouse is hovering over the editbox
				SpellEB[num]:SetScript("OnEnter", function()
					SpellEB[num]:SetScript("OnUpdate", RefSpellTip)
				end)
				SpellEB[num]:SetScript("OnLeave", function()
					SpellEB[num]:SetScript("OnUpdate", nil)
					GameTooltip:Hide();
				end)

				-- Create editbox for stack size
				SpellEB[num.."Stack"] = LeaPlusLC:CreateEditBox("SpellEB" .. num .. "Stack", SpellPanel, 30, 2, "TOPLEFT", x+80, y-20, "SpellEB" .. tab, "SpellEB" .. num);
				SpellEB[num.."Stack"]:SetNumeric(true);

				-- Create checkbox for pet spell
				LeaPlusLC:MakeCB(SpellPanel, "Spell" .. num .."Pet", "", 130, y-20, "")
				LeaPlusCB["Spell" .. num .."Pet"]:SetHitRectInsets(0, 0, 0, 0);

			end

			-- Add titles
			LeaPlusLC:MakeTx(SpellPanel, "Spell ID", 10, -60)
			LeaPlusLC:MakeTx(SpellPanel, "Stack", 84, -60)
			LeaPlusLC:MakeTx(SpellPanel, "Pet", 130, -60)

			-- Add editboxes and checkboxes
			MakeSpellEB(1, 10, -60, "2", "5")
			MakeSpellEB(2, 10, -90, "3", "1")
			MakeSpellEB(3, 10, -120, "4", "2")
			MakeSpellEB(4, 10, -150, "5", "3")
			MakeSpellEB(5, 10, -180, "1", "4")

			-- Add checkboxes
			LeaPlusLC:MakeTx(SpellPanel, "Options", 10, -240)
			LeaPlusLC:MakeCB(SpellPanel, "ShowSpellTips", "Show spell tooltips", 10, -260, "If checked, tooltips for the spell icons will be shown when you hover over them.", 2)
			LeaPlusLC:MakeCB(SpellPanel, "SpellIDonTip", "Show spell ID in tips", 10, -280, "If checked, spell IDs will be shown in the tooltips for beneficial spell icons situated in either the buff frame or under the target frame.", 2);
			LeaPlusLC:MakeCB(SpellPanel, "SpellOnPlayer", "Anchor to player", 10, -300, "If checked, spell icons will be shown above the player frame instead of the target frame.\n\nIf unchecked, spell icons will be shown above the target frame.", 2)

			-- Function to save the panel control settings and refresh the spell icons
			local function SaveClassControls()
				for i = 1, iCount do
					-- Show icons above target or player frame
					icon[i]:ClearAllPoints()
					if LeaPlusLC["SpellOnPlayer"] == "On" then
						icon[i]:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 116 + (22 * (i - 1)), 5)
						icon[i]:SetScale(PlayerFrame:GetScale());
					else
						icon[i]:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", 6 + (22 * (i - 1)), 5)
						icon[i]:SetScale(TargetFrame:GetScale());
					end

					-- Save control states to globals
					LeaPlusDC["SpellEB"..i] = SpellEB[i]:GetText();
					LeaPlusDC["SpellEB"..i.."Stack"] = SpellEB[i.."Stack"]:GetText();
					LeaPlusDC["Spell"..i.."Pet"] = LeaPlusCB["Spell" .. i .."Pet"]:GetChecked();

					-- Set spell icons
					if LeaPlusCB["Spell" .. i .."Pet"]:GetChecked() == 1 then
						ShowIcon(i, SpellEB[i]:GetText(), "pet");
					else
						ShowIcon(i, SpellEB[i]:GetText(), "player");
					end

					-- Show or hide spell icons depending on current buffs
					local newowner
					local newspell = GetSpellInfo(SpellEB[i]:GetText())
					if newspell then
						if LeaPlusDC["Spell"..i.."Pet"] then 
							newowner = "pet" 
						else
							newowner = "player"
						end
						-- Hide spell icon
						icon[i]:Hide()

						-- If buff matches spell we want, show spell icon
						local buff, void, void, stack, void, length, expire = UnitBuff(newowner, newspell)
						if buff then
							local stackval = tonumber(SpellEB[i.."Stack"]:GetText())
							if (stackval and stack >= stackval) or (not stackval) then
								icon[i]:Show()

								-- Set the icon cooldown to the buff cooldown
								CooldownFrame_SetTimer(icon[i].c, expire - length, length, 1)
							end
						end
					end
				end

			end

			-- Update spell icons when checkboxes are clicked
			LeaPlusCB["SpellOnPlayer"]:HookScript("OnClick", SaveClassControls)
			LeaPlusCB["ShowSpellTips"]:HookScript("OnClick", SaveClassControls)

			-- Create save button
			LeaPlusLC:CreateButton("SaveClassBtn", SpellPanel, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
			LeaPlusCB["SaveClassBtn"]:SetScript("OnClick", function()
				SpellPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show();
				return
			end)

			-- Create reset button
			LeaPlusLC:CreateButton("ResetClassBtn", SpellPanel, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
			LeaPlusCB["ResetClassBtn"]:SetScript("OnClick", function()
				-- Reset the checkboxes
				LeaPlusLC["ShowSpellTips"] = "On";
				LeaPlusLC["SpellIDonTip"] = "On";
				LeaPlusLC["SpellOnPlayer"] = "Off";
				for i = 1, iCount do
					-- Reset the panel controls
					SpellEB[i]:SetText("");
					SpellEB[i.."Stack"]:SetText("");
					LeaPlusDC["Spell" .. i .. "Pet"] = 0;
					-- Hide spell icons and clear scripts
					icon[i]:Hide();
					icon[i]:UnregisterEvent("UNIT_AURA")
					icon[i]:SetScript("OnEvent", nil);
					icon[i].z:SetScript("OnUpdate", nil);
					icon[i]:SetScript("OnEnter", nil);
					icon[i]:SetScript("OnLeave", nil);
				end
				SpellPanel:Hide(); SpellPanel:Show();
			end)

			-- Save editboxes when changed
			for i = 1, iCount do
				-- Set initial checkbox states
				LeaPlusCB["Spell" .. i .."Pet"]:SetChecked(LeaPlusDC["Spell"..i.."Pet"])
				-- Set checkbox states when shown
				LeaPlusCB["Spell" .. i .."Pet"]:SetScript("OnShow", function()
					LeaPlusCB["Spell" .. i .."Pet"]:SetChecked(LeaPlusDC["Spell"..i.."Pet"])
				end)
				-- Set states when changed
				SpellEB[i]:SetScript("OnTextChanged", SaveClassControls)
				SpellEB[i.."Stack"]:SetScript("OnTextChanged", SaveClassControls)
				LeaPlusCB["Spell" .. i .."Pet"]:SetScript("OnClick", SaveClassControls);
			end

			-- Show spell icons on startup
			SaveClassControls();

			-- Show panel when options panel button is clicked
			local function ShowSpellPanel()
				if IsShiftKeyDown() and IsControlKeyDown() then

					-- Get the character class
					local PlayerClass = select(2, UnitClass("player"))

					-- Top secret profile (ssh!)
					if PlayerClass == "HUNTER" then
						SpellEB[1]:SetText("136"); 		SpellEB["1Stack"]:SetText(""); 	LeaPlusDC["Spell1Pet"] = 1; -- Mend Pet
						SpellEB[2]:SetText("82692"); 	SpellEB["2Stack"]:SetText(""); 	LeaPlusDC["Spell2Pet"] = 0; -- Focus Fire
						SpellEB[3]:SetText(""); 		SpellEB["3Stack"]:SetText(""); 	LeaPlusDC["Spell3Pet"] = 0;
						SpellEB[4]:SetText(""); 		SpellEB["4Stack"]:SetText(""); 	LeaPlusDC["Spell4Pet"] = 0;
						SpellEB[5]:SetText(""); 		SpellEB["5Stack"]:SetText(""); 	LeaPlusDC["Spell5Pet"] = 0;

					elseif PlayerClass == "DRUID" then
						SpellEB[1]:SetText("69369"); 	SpellEB["1Stack"]:SetText(""); 	LeaPlusDC["Spell1Pet"] = 0; -- Predator's Swiftness
						SpellEB[2]:SetText("62606"); 	SpellEB["2Stack"]:SetText(""); 	LeaPlusDC["Spell2Pet"] = 0; -- Savage Defense
						SpellEB[3]:SetText(""); 		SpellEB["3Stack"]:SetText(""); 	LeaPlusDC["Spell3Pet"] = 0;
						SpellEB[4]:SetText(""); 		SpellEB["4Stack"]:SetText(""); 	LeaPlusDC["Spell4Pet"] = 0;
						SpellEB[5]:SetText("33763"); 	SpellEB["5Stack"]:SetText("3"); LeaPlusDC["Spell5Pet"] = 0; -- Lifebloom

					elseif PlayerClass == "MAGE" then
						SpellEB[1]:SetText("11426"); 	SpellEB["1Stack"]:SetText("");	LeaPlusDC["Spell1Pet"] = 0; -- Ice Barrier
						SpellEB[2]:SetText("108839"); 	SpellEB["2Stack"]:SetText("");	LeaPlusDC["Spell2Pet"] = 0; -- Ice Floes
						SpellEB[3]:SetText(""); 		SpellEB["3Stack"]:SetText(""); 	LeaPlusDC["Spell3Pet"] = 0;
						SpellEB[4]:SetText("61316"); 	SpellEB["4Stack"]:SetText(""); 	LeaPlusDC["Spell4Pet"] = 0; -- Dalaran Brilliance
						SpellEB[5]:SetText("116257"); 	SpellEB["5Stack"]:SetText(""); 	LeaPlusDC["Spell5Pet"] = 0; -- Invoker's Energy

					elseif PlayerClass == "WARRIOR" then
						SpellEB[1]:SetText("32216");	SpellEB["1Stack"]:SetText(""); 	LeaPlusDC["Spell1Pet"] = 0; -- Victory Rush
						SpellEB[2]:SetText(""); 		SpellEB["2Stack"]:SetText(""); 	LeaPlusDC["Spell2Pet"] = 0;
						SpellEB[3]:SetText(""); 		SpellEB["3Stack"]:SetText(""); 	LeaPlusDC["Spell3Pet"] = 0;
						SpellEB[4]:SetText(""); 		SpellEB["4Stack"]:SetText(""); 	LeaPlusDC["Spell4Pet"] = 0;
						SpellEB[5]:SetText("6673"); 	SpellEB["5Stack"]:SetText(""); 	LeaPlusDC["Spell5Pet"] = 0; -- Battle Shout

					elseif PlayerClass == "PALADIN" then
						SpellEB[1]:SetText("84963"); 	SpellEB["1Stack"]:SetText(""); 	LeaPlusDC["Spell1Pet"] = 0; -- Inquisition
						SpellEB[2]:SetText("20925"); 	SpellEB["2Stack"]:SetText(""); 	LeaPlusDC["Spell2Pet"] = 0; -- Sacred Shield
						SpellEB[3]:SetText(""); 		SpellEB["3Stack"]:SetText(""); 	LeaPlusDC["Spell3Pet"] = 0;
						SpellEB[4]:SetText(""); 		SpellEB["4Stack"]:SetText(""); 	LeaPlusDC["Spell4Pet"] = 0;
						SpellEB[5]:SetText("19740"); 	SpellEB["5Stack"]:SetText(""); 	LeaPlusDC["Spell5Pet"] = 0; -- Blessing of Might

					elseif PlayerClass == "PRIEST" then
						SpellEB[1]:SetText("17"); 		SpellEB["1Stack"]:SetText(""); 	LeaPlusDC["Spell1Pet"] = 0; -- Power Word: Shield
						SpellEB[2]:SetText("139"); 		SpellEB["2Stack"]:SetText(""); 	LeaPlusDC["Spell2Pet"] = 0; -- Renew
						SpellEB[3]:SetText(""); 		SpellEB["3Stack"]:SetText(""); 	LeaPlusDC["Spell3Pet"] = 0;
						SpellEB[4]:SetText(""); 		SpellEB["4Stack"]:SetText(""); 	LeaPlusDC["Spell4Pet"] = 0;
						SpellEB[5]:SetText("21562"); 	SpellEB["5Stack"]:SetText(""); 	LeaPlusDC["Spell5Pet"] = 0; -- Power Word: Fortitude

					elseif PlayerClass == "SHAMAN" then
						SpellEB[1]:SetText("324"); 		SpellEB["1Stack"]:SetText(""); 	LeaPlusDC["Spell1Pet"] = 0; -- Lightning Shield
						SpellEB[2]:SetText("114893"); 	SpellEB["2Stack"]:SetText("");	LeaPlusDC["Spell2Pet"] = 0; -- Stone Bulwark
						SpellEB[3]:SetText(""); 		SpellEB["3Stack"]:SetText(""); 	LeaPlusDC["Spell3Pet"] = 0;
						SpellEB[4]:SetText(""); 		SpellEB["4Stack"]:SetText(""); 	LeaPlusDC["Spell4Pet"] = 0;
						SpellEB[5]:SetText(""); 		SpellEB["5Stack"]:SetText(""); 	LeaPlusDC["Spell5Pet"] = 0;
		
					elseif PlayerClass == "ROGUE" then
						SpellEB[1]:SetText("5171");		SpellEB["1Stack"]:SetText(""); 	LeaPlusDC["Spell1Pet"] = 0; -- Slice abd Dice
						SpellEB[2]:SetText("1966"); 	SpellEB["2Stack"]:SetText(""); 	LeaPlusDC["Spell2Pet"] = 0; -- Feint
						SpellEB[3]:SetText(""); 		SpellEB["3Stack"]:SetText(""); 	LeaPlusDC["Spell3Pet"] = 0;
						SpellEB[4]:SetText(""); 		SpellEB["4Stack"]:SetText(""); 	LeaPlusDC["Spell4Pet"] = 0;
						SpellEB[5]:SetText("73651"); 	SpellEB["5Stack"]:SetText(""); 	LeaPlusDC["Spell5Pet"] = 0; -- Recuperate

					elseif PlayerClass == "MONK" then
						SpellEB[1]:SetText("125359");	SpellEB["1Stack"]:SetText(""); 	LeaPlusDC["Spell1Pet"] = 0; -- Slice abd Dice
						SpellEB[2]:SetText("125195"); 	SpellEB["2Stack"]:SetText("");	LeaPlusDC["Spell2Pet"] = 0; -- Recuperate
						SpellEB[3]:SetText(""); 		SpellEB["3Stack"]:SetText(""); 	LeaPlusDC["Spell3Pet"] = 0;
						SpellEB[4]:SetText("116781"); 	SpellEB["4Stack"]:SetText(""); 	LeaPlusDC["Spell4Pet"] = 0; -- Legacy of the White Tiger
						SpellEB[5]:SetText("117666"); 	SpellEB["5Stack"]:SetText(""); 	LeaPlusDC["Spell5Pet"] = 0; -- Legacy of the Emperor

					end

					LeaPlusLC["ShowSpellTips"] = "On";
					LeaPlusLC["SpellIDonTip"] = "On";
					LeaPlusLC["SpellOnPlayer"] = "Off";
					SpellPanel:Show(); SpellPanel:Hide();
					SaveClassControls();

				else

					-- Show spell panel
					SpellPanel:Show();
					LeaPlusLC:HideFrames();

				end

			end

			LeaPlusCB["SpellIconsBtn"]:SetScript("OnClick", ShowSpellPanel);

			-- Function to show spell ID in tooltips
			local function SpellIDonTip(unit, target, index)
				if LeaPlusLC["SpellIDonTip"] == "On" then
					local spellid = select(11, UnitAura(target, index));
					if spellid then
						GameTooltip:AddLine("Spell ID: " .. spellid)
						GameTooltip:Show();
					end
				end
			end

			-- Add spell ID to tooltip when icons in the buff frame are hovered
			hooksecurefunc(GameTooltip, 'SetUnitAura', SpellIDonTip)   

			-- Add spell ID to tooltip when icons in the target frame are hovered
			hooksecurefunc(GameTooltip, 'SetUnitBuff', SpellIDonTip)

		end
 				
		----------------------------------------------------------------------
		-- Coordinates
		----------------------------------------------------------------------

		if LeaPlusLC["StaticCoordsEn"] == "On" then

			-- Create movable coordinates frame
			local StaticCoordBox = CreateFrame("Frame", nil, UIParent)
			LeaPlusLC["StaticCoordBox"] = StaticCoordBox
			StaticCoordBox:Hide(); StaticCoordBox:EnableMouse(true);
			StaticCoordBox:SetClampedToScreen(true);
			StaticCoordBox:ClearAllPoints(); StaticCoordBox:SetPoint(LeaPlusLC["CoordsA"], UIParent, LeaPlusLC["CoordsR"], LeaPlusLC["CoordsX"], LeaPlusLC["CoordsY"]);
			StaticCoordBox:SetMovable(true); StaticCoordBox:RegisterForDrag("LeftButton")
			StaticCoordBox:SetScript("OnDragStart", StaticCoordBox.StartMoving)
			StaticCoordBox:SetScript("OnDragStop", function ()
				StaticCoordBox:StopMovingOrSizing();
				StaticCoordBox:SetUserPlaced(false);
				LeaPlusLC["CoordsA"], void, LeaPlusLC["CoordsR"], LeaPlusLC["CoordsX"], LeaPlusLC["CoordsY"] = StaticCoordBox:GetPoint();
			end)
			StaticCoordBox.t = StaticCoordBox:CreateTexture(nil, "BACKGROUND"); StaticCoordBox.t:SetAllPoints(); StaticCoordBox.t:SetTexture(0.05, 0.05, 0.05, 0.8)

			local Splay = CreateFrame("FRAME", nil, StaticCoordBox)
			Splay:SetWidth(38); Splay:SetHeight(16);
			Splay:SetPoint("TOPLEFT", 2, -2)

			Splay.x = Splay:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") 
			Splay.x:SetAllPoints(); Splay.x:SetJustifyH"LEFT";

			Splay.y = Splay:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") 
			Splay.y:SetPoint("LEFT", Splay.x, "RIGHT", 10, 0);
			Splay.y:SetJustifyH"LEFT";

			local stimer = 0; -- Internal timer for OnUpdate
			local vplayx, vplayy -- Raw coordinates

			local function ShowStaticCoordinates(self, elapsed)
				stimer = stimer + elapsed;
				if stimer > 0.2 then
					vplayx, vplayy = GetPlayerMapPosition("player")
					if vplayx > 0 and vplayy > 0 then
						Splay.x:SetFormattedText("%0.1f", (floor(vplayx * 1000 + 0.5)) / 10)
						Splay.y:SetFormattedText("%0.1f", (floor(vplayy * 1000 + 0.5)) / 10)
					else
						Splay.x:SetText("00.0");
						Splay.y:SetText("00.0");
					end
					stimer = 0;
				end
			end

			-- Calculate coordinates (only runs if coordinates are showing)
			StaticCoordBox:SetScript("OnUpdate", ShowStaticCoordinates)

			-- Create side panel
			local StaticPanel = LeaPlusLC:CreateSidePanel("Coordinates", 164, 280)

			LeaPlusLC:MakeTx(StaticPanel, "Coordinates Frame", 10, -60)
			LeaPlusLC:MakeCB(StaticPanel, "StaticCoords", "Show coordinates", 10, -80, "If checked, the coordinates frame will be enabled and you will be able to see it based on the settings below.\n\nIf you have the minimap button enabled, you can hold down SHIFT and right-click it to toggle this setting at any time.\n\nIf unchecked, the coordinates frame will be disabled and no CPU power will be allocated to updating them.", 2)
			LeaPlusLC:MakeCB(StaticPanel, "StaticCoordsBack", "Show background", 10, -100, "If checked, the coordinates frame will have a dark background.", 2)
			LeaPlusLC:MakeCB(StaticPanel, "StaticCoordsTop", "Show on top", 10, -120, "If checked, the coordinates frame will show over the top of most frames.", 2)
			LeaPlusLC:MakeCB(StaticPanel, "StaticCoordsLock", "Lock coordinates", 10, -140, "If checked, the coordinates frame will be locked and you will not be able to move it.\n\nEnabling this option will make the coordinates frame non-interactive, meaning you will be able to click through it as if it wasn't there.\n\nThis is useful if you are showing the coordinates in a space where you would normally click (such as the game world or minimap).", 2)

			LeaPlusLC:MakeTx(StaticPanel, "Scale", 10, -180)
			LeaPlusLC:MakeSL(StaticPanel, "StaticCoordsScale", "", 0.9, 2.2, 0.1, 10, -200, "%.1f")

			-- Function to show coordinates based on options (run by many handlers)
			local function RefreshStaticCoords()
				-- Show or hide coordinates
				if LeaPlusLC["StaticCoords"] == "On" then
					-- Show coordinates and set map to current zone
					StaticCoordBox:Show();
					SetMapToCurrentZone();
				else
					StaticCoordBox:Hide();
				end
				-- Show or hide the background
				if LeaPlusLC["StaticCoordsBack"] == "On" then
					StaticCoordBox.t:Show();
				else
					StaticCoordBox.t:Hide();
				end
				-- Set scale of coordinates
				local scale = LeaPlusLC["StaticCoordsScale"]
				StaticCoordBox:SetWidth(90 * scale);
				StaticCoordBox:SetHeight(18 * scale);
				Splay:SetScale(scale);
				-- Set locked status
				if LeaPlusLC["StaticCoordsLock"] == "On" then
					StaticCoordBox:SetScript("OnDragStart", nil);
					StaticCoordBox:EnableMouse(false);
				else
					StaticCoordBox:SetScript("OnDragStart", StaticCoordBox.StartMoving)
					StaticCoordBox:EnableMouse(true);
				end
				-- Show on top
				if LeaPlusLC["StaticCoordsTop"] == "On" then
					StaticCoordBox:SetFrameStrata("HIGH")
				else
					StaticCoordBox:SetFrameStrata("MEDIUM")
				end
				-- Show coordinates
				if LeaPlusLC["StaticCoords"] == "On" then
					StaticCoordBox:Show();
				else
					StaticCoordBox:Hide();
				end
			end
		
			-- Assign file level scope to local function (so that the minimap button can run it)
			LeaPlusLC.RefreshStaticCoords = RefreshStaticCoords

			-- Refresh map when controls are clicked
			LeaPlusCB["StaticCoords"]:HookScript("OnClick", RefreshStaticCoords)
			LeaPlusCB["StaticCoordsBack"]:HookScript("OnClick", RefreshStaticCoords)
			LeaPlusCB["StaticCoordsScale"]:HookScript("OnValueChanged", RefreshStaticCoords)
			LeaPlusCB["StaticCoordsLock"]:HookScript("OnClick", RefreshStaticCoords)
			LeaPlusCB["StaticCoordsTop"]:HookScript("OnClick", RefreshStaticCoords)

			-- Hide coordinates frame when battle pet frame is shown
			hooksecurefunc("PetBattleFrame_Display", function() 
				if LeaPlusLC["StaticCoords"] == "On" then
					LeaPlusLC["StaticCoordBox"]:Hide();
				end
			end)

			-- Refresh coordinates when battle frame is hidden
			hooksecurefunc("PetBattleFrame_Remove", function() 
				if LeaPlusLC["StaticCoords"] == "On" then
					RefreshStaticCoords();
				end
			end)

			-- Hide coordinates frame when world map is shown
			local function HideWithMap()
				if LeaPlusLC["StaticCoords"] == "On" then
					if WorldMapFrame:IsShown() then
						StaticCoordBox:Hide();
					else
						StaticCoordBox:Show();
					end
				end
			end

			WorldMapFrame:HookScript("OnShow", HideWithMap);
			WorldMapFrame:HookScript("OnHide", HideWithMap);

			-- Hide coordinates if they are showing when world map is shown
			StaticCoordBox:HookScript("OnShow", function()
				if WorldMapFrame:IsShown() then
					StaticCoordBox:Hide()
				end
			end)

			-- Load settings on startup
			RefreshStaticCoords();

			-- Create save button
			LeaPlusLC:CreateButton("SaveStaticBtn", StaticPanel, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
			LeaPlusCB["SaveStaticBtn"]:SetScript("OnClick", function()
				StaticPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show();
				return
			end)

			-- Create reset button
			LeaPlusLC:CreateButton("ResetStaticBtn", StaticPanel, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
			LeaPlusCB["ResetStaticBtn"]:SetScript("OnClick", function()

				-- Reset checkboxes
				LeaPlusLC["StaticCoords"] = "On"
				LeaPlusLC["StaticCoordsBack"] = "Off"
				LeaPlusLC["StaticCoordsScale"] = 2.2;
				LeaPlusLC["StaticCoordsLock"] = "Off";
				LeaPlusLC["StaticCoordsTop"] = "Off";
				RefreshStaticCoords();

				-- Reset coordinates frame location
				LeaPlusLC["CoordsA"], LeaPlusLC["CoordsR"], LeaPlusLC["CoordsX"], LeaPlusLC["CoordsY"] = "CENTER", "CENTER", 0, 0
				StaticCoordBox:ClearAllPoints();
				StaticCoordBox:SetPoint(LeaPlusLC["CoordsA"], UIParent, LeaPlusLC["CoordsR"], LeaPlusLC["CoordsX"], LeaPlusLC["CoordsY"]);

				-- Refresh side panel
				StaticPanel:Hide(); StaticPanel:Show();

			end)

			-- Show side panal when options panel button is clicked
			LeaPlusCB["ModStaticCoordsBtn"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Private profile
					LeaPlusLC["StaticCoords"] = "Off"
					LeaPlusLC["StaticCoordsBack"] = "Off"
					LeaPlusLC["StaticCoordsScale"] = 2.2;
					LeaPlusLC["StaticCoordsLock"] = "Off";
					LeaPlusLC["StaticCoordsTop"] = "Off";
					LeaPlusLC["CoordsA"], LeaPlusLC["CoordsR"], LeaPlusLC["CoordsX"], LeaPlusLC["CoordsY"] = "BOTTOMRIGHT", "BOTTOMRIGHT", -300, 130
					StaticCoordBox:ClearAllPoints();
					StaticCoordBox:SetPoint(LeaPlusLC["CoordsA"], UIParent, LeaPlusLC["CoordsR"], LeaPlusLC["CoordsX"], LeaPlusLC["CoordsY"]);
					RefreshStaticCoords();
				else
					StaticPanel:Show();
					LeaPlusLC:HideFrames();
				end
			end);

			-- Refresh map when zone changes if coordinates are showing (so that coordinates update to new zone)
			local function UpdateMapZone()
				if LeaPlusLC["StaticCoords"] == "On" then
					if StaticCoordBox:IsShown() then
						SetMapToCurrentZone();
					end
				end
			end

			StaticCoordBox:RegisterEvent("ZONE_CHANGED_NEW_AREA");
			StaticCoordBox:RegisterEvent("ZONE_CHANGED");
			StaticCoordBox:RegisterEvent("ZONE_CHANGED_INDOORS");
			StaticCoordBox:RegisterEvent("NEW_WMO_CHUNK");
			StaticCoordBox:SetScript("OnEvent", UpdateMapZone);	

		end

		----------------------------------------------------------------------
		-- Minimap customisation
		----------------------------------------------------------------------

		if LeaPlusLC["MinimapMod"] == "On" then

			-- Create minimap modification side panel
			local SideMinimap = LeaPlusLC:CreateSidePanel("Minimap", 164, 280)

			-- Update minimap when slider control changes
			local function RefreshMinimap()
				MinimapCluster:SetScale(LeaPlusLC["MinimapScale"])
			end

			-- Add checkboxes
			LeaPlusLC:MakeTx(SideMinimap, "Features", 10, -60)
			LeaPlusLC:MakeCB(SideMinimap, "MergeTrackBtn", "Merge buttons", 10, -80, "If checked, the minimap tracking button will be merged with the calendar button to save space.\n\nThe new tracking button will be moved to the space normally occupied by the calendar button.\n\nYou will be able to left-click the tracking button to show the tracking menu and right-click it to show the calendar.", 2)
			LeaPlusLC:MakeCB(SideMinimap, "HideMinimapZone", "Hide zone text", 10, -100, "If checked, the zone information shown above the minimap, as well as the world map button, will be hidden.\n\nThe tooltip for the tracking button will show zone text information instead.\n\nTo show the world map, press the map bind key (M by default).", 2)
			LeaPlusLC:MakeCB(SideMinimap, "HideMinimapTime", "Hide clock", 10, -120, "If checked, the clock will be hidden.", 2)
			LeaPlusLC:MakeCB(SideMinimap, "MinimapMouseZoom", "Mousewheel zoom", 10, -140, "If checked, you will be able to use the mousewheel to zoom in and out of the minimap.  The zoom in/out buttons will be hidden.", 2)

			-- Create slider control
			LeaPlusLC:MakeTx(SideMinimap, "Scale", 10, -180)
			LeaPlusLC:MakeSL(SideMinimap, "MinimapScale", "", 0.5, 3, 0.1, 10, -200, "%.2f")
			LeaPlusCB["MinimapScale"]:HookScript("OnValueChanged", RefreshMinimap)

			-- Store Blizzard handlers
			local origMiniMapTrackingButtonOnEnter = MiniMapTrackingButton:GetScript('OnEnter')
			local zonta,zontp,zontr,zontx,zonty = MinimapZoneTextButton:GetPoint();

			local function ShowZoneTip()
				if LeaPlusLC["HideMinimapZone"] == "On" then
					-- Show zone information in tooltip
					local zoneName = GetZoneText();
					local subzoneName = GetSubZoneText();
					if ( subzoneName == zoneName ) then
						subzoneName = "";	
					end
					-- Change the owner and position (needed for Minimap_SetTooltip)
					GameTooltip:SetOwner(MinimapZoneTextButton, "ANCHOR_LEFT")
					MinimapZoneTextButton:SetAllPoints(MiniMapTrackingButton)
					-- Show the tooltip
					local pvpType, isSubZonePvP, factionName = GetZonePVPInfo();
					Minimap_SetTooltip( pvpType, factionName )
					GameTooltip:Show();
				else
					MinimapZoneTextButton:ClearAllPoints();
					MinimapZoneTextButton:SetPoint(zonta,zontp,zontr,zontx,zonty)
				end
			end

			-- Merge buttons
			local function UpdateMiniMergeButtons()
				if LeaPlusLC["MergeTrackBtn"] == "On" then
					-- Hide calendar button
					GameTimeFrame:Hide();
					-- Move the tracking button to the calendar button space
					MiniMapTracking:ClearAllPoints();
					MiniMapTracking:SetAllPoints(GameTimeFrame);
					-- Right-clicking the tracking button shows the calendar 
					MiniMapTrackingButton:SetScript("OnMouseDown", function(self, btn)
						if btn == "RightButton" then GameTimeFrame:Click();	end
					end)
				else
					-- Show the calendar button
					GameTimeFrame:Show();
					-- Move the tracking button to its origianl position
					MiniMapTracking:ClearAllPoints();
					MiniMapTracking:SetPoint("TOPLEFT", MinimapBackdrop, "TOPLEFT", 9, -45);
					-- Remove right-click from the tracking button
					MiniMapTrackingButton:SetScript("OnMouseDown", nil);
				end
			end

			-- When the merge buttons option is checked, update the minimap
			LeaPlusCB["MergeTrackBtn"]:HookScript("OnClick", UpdateMiniMergeButtons);

			-- Update the minimap on startup
			UpdateMiniMergeButtons();

			-- Hide controls during combat
			SideMinimap:RegisterEvent("PLAYER_REGEN_DISABLED")
			SideMinimap:SetScript("OnEvent", SideMinimap.Hide)

			-- Hide minimap zone text
			local function UpdateMiniZoneText()
				if LeaPlusLC["HideMinimapZone"] == "On" then
					-- Hide the minimap zone information and world map button
					MinimapZoneTextButton:Hide(); MiniMapWorldMapButton:Hide();
					MinimapBorderTop:SetTexture("");
					-- Move the minimap up to the top
					MinimapCluster:ClearAllPoints(); MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 20);
					-- Set the tooltip of the tracking button as the zone name
					MiniMapTrackingButton:SetScript("OnEnter", ShowZoneTip);
				else
					-- Show the minimap zone information and world map button
					MinimapZoneTextButton:Show(); MiniMapWorldMapButton:Show();
					MinimapBorderTop:SetTexture("Interface\\Minimap\\UI-Minimap-Border");
					-- Move the minimap to its original position
					MinimapCluster:ClearAllPoints(); MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0);
					-- Set the tooltip of the tracking button as the original one
					MiniMapTrackingButton:SetScript("OnEnter", origMiniMapTrackingButtonOnEnter);
				end
			end

			-- Function to show tooltip text
			local function ShowTextAndTip()
				UpdateMiniZoneText(); 
				ShowZoneTip();
			end

			-- When the hide zone text option is checked, update the minimap
			LeaPlusCB["HideMinimapZone"]:HookScript("OnClick", ShowTextAndTip);

			-- Update the minimap on startup
			UpdateMiniZoneText();

			-- Hide the time
			if not IsAddOnLoaded("Blizzard_TimeManager") then
				LoadAddOn("Blizzard_TimeManager")
			end

			local function UpdateClock()
				if LeaPlusLC["HideMinimapTime"] == "On"	then
					TimeManagerClockButton:Hide();
				else
					TimeManagerClockButton:Show();
				end
			end

			-- Update the clock when the checkbox is clicked
			LeaPlusCB["HideMinimapTime"]:HookScript("OnClick", UpdateClock);
		
			-- Update the clock on startup
			UpdateClock();

			-- Use mousewheel to zoom
			local function MiniZoom(self, arg1)
				if arg1 > 0 and self:GetZoom() < 5 then
					self:SetZoom(self:GetZoom() + 1)
				elseif arg1 < 0 and self:GetZoom() > 0 then
					self:SetZoom(self:GetZoom() - 1)
				end
			end

			local function MiniZoomSet()
				if LeaPlusLC["MinimapMouseZoom"] == "On" then
					MinimapZoomIn:Hide()
					MinimapZoomOut:Hide()
					Minimap:EnableMouseWheel(true)
					Minimap:SetScript("OnMouseWheel", MiniZoom);
				else
					MinimapZoomIn:Show()
					MinimapZoomOut:Show()
					Minimap:EnableMouseWheel(false)
					Minimap:SetScript("OnMouseWheel", nil);
				end
			end

			-- Update the zoom setting when checkbox is clicked
			LeaPlusCB["MinimapMouseZoom"]:HookScript("OnClick", MiniZoomSet);
	
			-- Update the zoom setting on startup
			MiniZoomSet();

			-- Create save button
			LeaPlusLC:CreateButton("SaveMinimapBtn", SideMinimap, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
			LeaPlusCB["SaveMinimapBtn"]:SetScript("OnClick", function()
				-- Hide the side panel and show the options panel again
				SideMinimap:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show();
				return
			end)

			-- Create reset button
			LeaPlusLC:CreateButton("ResetMinimapBtn", SideMinimap, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
			LeaPlusCB["ResetMinimapBtn"]:SetScript("OnClick", function()
				-- Reset the minimap scale and refresh the side panel
				LeaPlusLC["MergeTrackBtn"] = "Off"
				UpdateMiniMergeButtons();
				LeaPlusLC["HideMinimapZone"] = "Off"
				UpdateMiniZoneText(); ShowTextAndTip();
				LeaPlusLC["HideMinimapTime"] = "Off"
				UpdateClock();
				LeaPlusLC["MinimapMouseZoom"] = "Off"
				MiniZoomSet();
				LeaPlusLC["MinimapScale"] = 1.00;
				RefreshMinimap();
				SideMinimap:Hide();
				SideMinimap:Show();
			end)

			-- Handler for options panel ? button
			LeaPlusCB["ModMinimapBtn"]:SetScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					if IsShiftKeyDown() and IsControlKeyDown() then

						-- Top secret profile (ssh!)
						LeaPlusLC["MergeTrackBtn"] = "On"; UpdateMiniMergeButtons();
						LeaPlusLC["HideMinimapZone"] = "On"
						UpdateMiniZoneText(); ShowTextAndTip();
						LeaPlusLC["HideMinimapTime"] = "Off"
						UpdateClock();
						LeaPlusLC["MinimapMouseZoom"] = "Off"
						MiniZoomSet();
						LeaPlusLC["MinimapScale"] = 1.30;
						RefreshMinimap();

					else

						-- Show side panel
						SideMinimap:Show();
						LeaPlusLC:HideFrames();

					end
				end
			end)

			-- Update minimap during loading time
			RefreshMinimap();

		end

		----------------------------------------------------------------------
		--	Quest detail text size
		----------------------------------------------------------------------

		if LeaPlusLC["QuestFontChange"] == "On" then

			-- Function to update the font size
			local function QuestSizeUpdate()
				QuestTitleFont:SetFont(QuestTitleFont:GetFont(), LeaPlusLC["LeaPlusQuestFontSize"] + 6, nil);
				QuestFont:SetFont(QuestFont:GetFont(), LeaPlusLC["LeaPlusQuestFontSize"] + 1, nil);
				QuestFontNormalSmall:SetFont(QuestFontNormalSmall:GetFont(), LeaPlusLC["LeaPlusQuestFontSize"], nil);
			end

			-- Set text size on startup
			QuestSizeUpdate();

			-- Set text size after changing slider
			LeaPlusCB["LeaPlusQuestFontSize"]:HookScript("OnValueChanged", QuestSizeUpdate);

		end

		----------------------------------------------------------------------
		--	Resize mail text
		----------------------------------------------------------------------

		if LeaPlusLC["MailFontChange"] == "On" then

			-- Function to update the font size
			local function MailSizeUpdate()
				local MailFont = QuestFont:GetFont();
				OpenMailBodyText:SetFont(MailFont, LeaPlusLC["LeaPlusMailFontSize"])
				SendMailBodyEditBox:SetFont(MailFont, LeaPlusLC["LeaPlusMailFontSize"])
			end

			-- Set text size on startup
			MailSizeUpdate();

			-- Set text size after changing slider
			LeaPlusCB["LeaPlusMailFontSize"]:HookScript("OnValueChanged", MailSizeUpdate);

		end

		----------------------------------------------------------------------
		--	Map customisation (first part)
		----------------------------------------------------------------------

		if LeaPlusLC["ShowMapMod"] == "On" then

			-- Set world map to mini size if map customisation is enabled (rest is done in variable)
			SetCVar("miniWorldMap", "1")

		end

		----------------------------------------------------------------------
		--	Show durability status
		----------------------------------------------------------------------

		if LeaPlusLC["DurabilityStatus"] == "On" then

			local Slots = {"HeadSlot", "ShoulderSlot", "ChestSlot", "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "MainHandSlot", "SecondaryHandSlot"}
			local SlotsFriendly = {INVTYPE_HEAD, INVTYPE_SHOULDER, INVTYPE_CHEST, INVTYPE_WRIST, INVTYPE_HAND, INVTYPE_WAIST, INVTYPE_LEGS, INVTYPE_FEET, INVTYPE_WEAPONMAINHAND, INVTYPE_WEAPONOFFHAND}

			-- Show durability status in tooltip or status line (tip or status)
			local function ShowDuraStats(where)

				local duravaltotal, duramaxtotal, durapercent = 0, 0, 0
				local valcol, id, duraval, duramax

				if where == "tip" then
					-- Creare layout
					_G["GameTooltipTextLeft1"]:SetText("|cffffffff"); _G["GameTooltipTextRight1"]:SetText("|cffffffff")
					_G["GameTooltipTextLeft2"]:SetText("|cffffffff"); _G["GameTooltipTextRight2"]:SetText("|cffffffff")
					GameTooltip:AddLine("|cffffffff")
					GameTooltip:AddLine("|cffffffff")
				end

				-- Traverse equipment slots
				for k, slotName in ipairs(Slots) do
					if GetInventorySlotInfo(slotName) then
						id = GetInventorySlotInfo(slotName)
						duraval, duramax = GetInventoryItemDurability(id)
						if duraval ~= nil then

							-- Add to tooltip (hack)
							if where == "tip" then
								durapercent = tonumber(format("%.0f", duraval / duramax * 100))
								valcol = (durapercent >= 80 and "|cff00FF00") or (durapercent >= 60 and "|cff99FF00") or (durapercent >= 40 and "|cffFFFF00") or (durapercent >= 20 and "|cffFF9900") or (durapercent >= 0 and "|cffFF2000") or ("|cffFFFFFF")
								_G["GameTooltipTextLeft1"]:SetText("Durability")
								_G["GameTooltipTextLeft2"]:SetText(_G["GameTooltipTextLeft2"]:GetText() .. SlotsFriendly[k] .. "\n")
								_G["GameTooltipTextRight2"]:SetText(_G["GameTooltipTextRight2"]:GetText() ..  valcol .. durapercent .. "%" .. "\n")
							end

							duravaltotal = duravaltotal + duraval
							duramaxtotal = duramaxtotal + duramax
						end
					end
				end
				durapercent = duravaltotal / duramaxtotal * 100 or -1

				if where == "tip" then

					-- Show overall durability in the tooltip
					if durapercent >= 80 then valcol = "|cff00FF00"	elseif durapercent >= 60 then valcol = "|cff99FF00"	elseif durapercent >= 40 then valcol = "|cffFFFF00"	elseif durapercent >= 20 then valcol = "|cffFF9900"	elseif durapercent >= 0 then valcol = "|cffFF2000" else return end
						_G["GameTooltipTextLeft2"]:SetText(_G["GameTooltipTextLeft2"]:GetText() .. "\nOverall " .. valcol)
						_G["GameTooltipTextRight2"]:SetText(_G["GameTooltipTextRight2"]:GetText() .. "\n" .. valcol .. string.format("%.0f", durapercent) .. "%")

						-- Show both lines of the tooltip (yep, just two)
						GameTooltipTextLeft1:Show(); GameTooltipTextRight1:Show();
						GameTooltipTextLeft2:Show(); GameTooltipTextRight2:Show();
						GameTooltipTextRight2:SetJustifyH"RIGHT";
						GameTooltip:Show();

				elseif where == "status" then
					-- Show simple status line instead
					if tonumber(durapercent) >= 0 then -- Ensure character has some durability items equipped
						LeaPlusLC:Print("You have " .. string.format("%.0f", durapercent) .. "%" .. " durability.")
					end
				end
			end

			-- Hook the tooltip to the expand button on the character frame
			CharacterFrameExpandButton:SetScript("OnEnter", function()
				GameTooltip:SetOwner(CharacterFrameExpandButton, "ANCHOR_RIGHT");
				ShowDuraStats("tip");
			end)

			-- Create frame to watch for characters coming back to life
			local DeathDura = CreateFrame("FRAME")
			DeathDura:RegisterEvent("PLAYER_DEAD")
			DeathDura:SetScript("OnEvent", function(self, event)
				ShowDuraStats("status")
			end)

			hooksecurefunc("AcceptResurrect", function()
				-- Player has ressed without releasing
				ShowDuraStats("status")
			end)
			
		end

		----------------------------------------------------------------------
		--	Hide loot won alerts
		----------------------------------------------------------------------

		if LeaPlusLC["NoLootWonAlert"] == "On" then
			local function NoLootAlert()
				LootWonAlertFrame1:Hide()
				BonusRollLootWonFrame:Hide();
				BonusRollMoneyWonFrame:Hide();
			end;
			LootWonAlertFrame1:SetScript("OnShow", NoLootAlert);
			BonusRollLootWonFrame:SetScript("OnShow", NoLootAlert);
			BonusRollMoneyWonFrame:SetScript("OnShow", NoLootAlert);
		end

		----------------------------------------------------------------------
		--	Hide character controls
		----------------------------------------------------------------------

		if LeaPlusLC["NoCharControls"] == "On" then
			CharacterModelFrameControlFrame:HookScript("OnShow", CharacterModelFrameControlFrame.Hide);
			DressUpModelControlFrame:HookScript("OnShow", DressUpModelControlFrame.Hide);
			SideDressUpModelControlFrame:HookScript("OnShow", SideDressUpModelControlFrame.Hide);
		end

		----------------------------------------------------------------------
		--	Zone text
		----------------------------------------------------------------------

		if LeaPlusLC["HideZoneText"] == "On" then
			ZoneTextFrame:SetScript("OnShow", ZoneTextFrame.Hide);
		end

		----------------------------------------------------------------------
		--	Subzone text
		----------------------------------------------------------------------

		if LeaPlusLC["HideSubzoneText"] == "On" then
			SubZoneTextFrame:SetScript("OnShow", SubZoneTextFrame.Hide);
		end

		----------------------------------------------------------------------
		--	Disable sticky chat
		----------------------------------------------------------------------

		-- Set these to nil because they taint if set to 0
		if LeaPlusLC["NoStickyChat"] == "On" then
			ChatTypeInfo.WHISPER.sticky = nil
			ChatTypeInfo.BN_WHISPER.sticky = nil
			ChatTypeInfo.CHANNEL.sticky = nil
		end

		----------------------------------------------------------------------
		--	Arrow keys in chat
		----------------------------------------------------------------------

		if LeaPlusLC["UseArrowKeysInChat"] == "On" then
			-- Enable arrow keys for normal chat frames
			for i = 1, NUM_CHAT_WINDOWS, 1 do
				_G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false)
			end
			-- Enable arrow keys for temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf .. "EditBox"]:SetAltArrowKeyMode(false)
				end
			end)
		end

		----------------------------------------------------------------------
		--	Hide stance bar
		----------------------------------------------------------------------

		if LeaPlusLC["NoClassBar"] == "On" then
			local stancebar = CreateFrame("FRAME")
			stancebar:Hide();
			UIPARENT_MANAGED_FRAME_POSITIONS["StanceBarFrame"] = nil;
			StanceBarFrame:SetParent(stancebar)
		end
		
		----------------------------------------------------------------------
		--	Remove raid restrictions
		----------------------------------------------------------------------

		if LeaPlusLC["NoRaidRestrictions"] == "On" then
			SetAllowLowLevelRaid(1);
		end

		----------------------------------------------------------------------
		--	Hide gryphons
		----------------------------------------------------------------------

		if LeaPlusLC["NoGryphons"] == "On" then
			MainMenuBarLeftEndCap:Hide();
			MainMenuBarRightEndCap:Hide();
		end

		----------------------------------------------------------------------
		--	Disable chat fade
		----------------------------------------------------------------------

		if LeaPlusLC["NoChatFade"] == "On" then
			-- Process normal chat frames
			for i = 1, NUM_CHAT_WINDOWS do
				_G[("ChatFrame" .. i)]:SetFading(false)
			end
			-- Process temporary frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf]:SetFading(false)
				end
			end)
		end

		----------------------------------------------------------------------
		--	Prevent bag automation
		----------------------------------------------------------------------

		if LeaPlusLC["NoBagAutomation"] == "On" then
			local function GoAwayBags() return end
			OpenAllBags = GoAwayBags;
			CloseAllBags = GoAwayBags;
		end

		----------------------------------------------------------------------
		--	Tooltip anchor to mouse
		----------------------------------------------------------------------

		if LeaPlusLC["TipModEnable"] == "On" then
			if (LeaPlusLC["TipAnchorToMouse"] == "On") then

				-- Disable fading for certain UI elements (such as player frame)
				GameTooltip.FadeOut = GameTooltip.Hide;

				-- Variables are scoped out of OnUpdate and given values during SetDefaultAnchor to save CPU power
				local realanc; -- Used to store anchor to cursor offset

				-- Set default anchor (for objects and UI elements)
				hooksecurefunc("GameTooltip_SetDefaultAnchor", function (tooltip, parent)
					realanc = LeaPlusLC["TipMouseAnchorTable"][LeaPlusLC["TipMouseAnchor"]]
					GameTooltip:SetOwner(UIParent, "ANCHOR_NONE");
					GameTooltip:SetPoint(LeaPlusLC["TipPosAnchor"], UIParent, LeaPlusLC["TipPosRelative"], LeaPlusLC["TipPosXOffset"], LeaPlusLC["TipPosYOffset"]);
				end)

				-- Anchor pet battle ability tooltips
				hooksecurefunc("PetBattleAbilityTooltip_Show", function(self)
					PetBattlePrimaryAbilityTooltip:ClearAllPoints()
					PetBattlePrimaryAbilityTooltip:SetPoint(LeaPlusLC["TipPosAnchor"], UIParent, LeaPlusLC["TipPosRelative"], LeaPlusLC["TipPosXOffset"], LeaPlusLC["TipPosYOffset"]);
				end)

				-- Hook tooltip update function to position and hide tooltips
				GameTooltip:HookScript("OnUpdate", function(frame, elapsed)
					if GetMouseFocus() == WorldFrame then
						if LeaPlusLC["TipHideCombat"] == "On" and (UnitAffectingCombat("player")) and not IsShiftKeyDown() then
							GameTooltip:SetAlpha(0);
						else
							GameTooltip:SetAlpha(LeaPlusLC["TipAlpha"]);
						end
						if UnitExists("mouseover") then
							if (frame.default) then
								local x, y = GetCursorPosition()
								local scale = frame:GetEffectiveScale()
								frame:ClearAllPoints() 
								frame:SetPoint(realanc, UIParent, "BOTTOMLEFT", (x/scale + LeaPlusLC["TipMouseOffsetX"]), (y/scale + LeaPlusLC["TipMouseOffsetY"]))
							end
						else
							if (GameTooltip:GetUnit("mouseover")) ~= nil then
								GameTooltip:SetOwner(UIParent, "ANCHOR_NONE");
								GameTooltip:SetPoint(LeaPlusLC["TipPosAnchor"], UIParent, LeaPlusLC["TipPosRelative"], LeaPlusLC["TipPosXOffset"], LeaPlusLC["TipPosYOffset"]);
							end
						end
					else
						local hasUnit, unit = GameTooltip:GetUnit()
						if hasUnit and not unit then
							GameTooltip:Hide();
						end
					end
				end)
			else

				-- Tooltip option without anchor to mouse (handled independently to save CPU power)
				hooksecurefunc("GameTooltip_SetDefaultAnchor", function (tooltip, parent)
					GameTooltip:SetOwner(UIParent, "ANCHOR_NONE");
					GameTooltip:SetPoint(LeaPlusLC["TipPosAnchor"], UIParent, LeaPlusLC["TipPosRelative"], LeaPlusLC["TipPosXOffset"], LeaPlusLC["TipPosYOffset"]);
				end)

				-- Anchor pet battle ability tooltips
				hooksecurefunc("PetBattleAbilityTooltip_Show", function(self)
					PetBattlePrimaryAbilityTooltip:ClearAllPoints()
					PetBattlePrimaryAbilityTooltip:SetPoint(LeaPlusLC["TipPosAnchor"], UIParent, LeaPlusLC["TipPosRelative"], LeaPlusLC["TipPosXOffset"], LeaPlusLC["TipPosYOffset"]);
				end)

			end
			
		end

		----------------------------------------------------------------------
		--	Use easy chat frame resizing
		----------------------------------------------------------------------

		if LeaPlusLC["UseEasyChatResizing"] == "On" then
			ChatFrame1Tab:HookScript("OnMouseDown", function(self,arg1)
				if arg1 == "LeftButton" then
					if select(8, GetChatWindowInfo(1)) then
						ChatFrame1:StartSizing("TOP")
					end
				end
			end)
			ChatFrame1Tab:SetScript("OnMouseUp", function(self,arg1)
				if arg1 == "LeftButton" then
					ChatFrame1:StopMovingOrSizing()
					FCF_SavePositionAndDimensions(ChatFrame1)
				end
			end)
		end

		----------------------------------------------------------------------
		--	Increase chat history length
		----------------------------------------------------------------------

		if LeaPlusLC["MaxChatHstory"] == "On" then
			-- Process normal chat frames
			for i = 1, NUM_CHAT_WINDOWS, 1 do
				if (_G["ChatFrame" .. i]:GetMaxLines() ~= 4096) then
					_G["ChatFrame" .. i]:SetMaxLines(4096);
				end
			end
			-- Process temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					if (_G[cf]:GetMaxLines() ~= 4096) then
						_G[cf]:SetMaxLines(4096);
					end
				end
			end)
		end

		----------------------------------------------------------------------
		--	Show quest levels
		----------------------------------------------------------------------

		if LeaPlusLC["ShowQuestLevels"] == "On" then

			-- Create table for tags (only needed if quest type tags are used)
			local QuestTags = {Elite = "+", Group = "G", Dungeon = "D", Raid = "R", PvP = "P", Daily = "!", Heroic = "H", Repeatable = "?"}

			-- Show quest levels
			local function QuestFunc()

				local buttons = QuestLogScrollFrame.buttons
				local QuestButtons = #buttons
				local QuestScrollOffset = HybridScrollFrame_GetOffset(QuestLogScrollFrame)
				local QuestEntries, void = GetNumQuestLogEntries()

				-- Go through quest log
				for i = 1, QuestButtons do
					local QuestIndex = i + QuestScrollOffset
					local QuestTitle = buttons[i]
					if QuestIndex <= QuestEntries then

						local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(QuestIndex)

						-- Add quest type
						if not isHeader or title then
							if not suggestedGroup or suggestedGroup == 0 then suggestedGroup = nil end
							title = string.format("[%s%s%s%s] %s", level, questTag and QuestTags[questTag] or "", isDaily and QuestTags.Daily or "",suggestedGroup or "", title), questTag, isDaily, isComplete
						end

						-- Show quest title with level
						if not isHeader then
							QuestTitle:SetText(title)
							QuestLogTitleButton_Resize(QuestTitle)
						end

					end
				end

			end

			hooksecurefunc('QuestLog_Update', QuestFunc)
			QuestLogScrollFrameScrollBar:HookScript('OnValueChanged', QuestFunc)

		end

		----------------------------------------------------------------------
		--	Hide error text
		----------------------------------------------------------------------

		if LeaPlusLC["HideErrorFrameText"] == "On" then
	
			local OrigErrHandler = UIErrorsFrame:GetScript('OnEvent')

			--	Error message events
			UIErrorsFrame:SetScript('OnEvent', function (self, event, err, ...)

				-- Handle error messages
				if event == "UI_ERROR_MESSAGE" then
					if LeaPlusLC["ShowErrorsFlag"] == 1 then
						if 	err == ERR_INV_FULL or
							err == ERR_QUEST_LOG_FULL or
							err == ERR_RAID_GROUP_ONLY	or
							err == ERR_PARTY_LFG_BOOT_LIMIT or
							err == ERR_PARTY_LFG_BOOT_DUNGEON_COMPLETE or
							err == ERR_PARTY_LFG_BOOT_IN_COMBAT or
							err == ERR_PARTY_LFG_BOOT_IN_PROGRESS or
							err == ERR_PARTY_LFG_BOOT_LOOT_ROLLS or
							err == ERR_PARTY_LFG_TELEPORT_IN_COMBAT or
							err == ERR_PET_SPELL_DEAD or
							err == ERR_PLAYER_DEAD or
							err:find(format(ERR_PARTY_LFG_BOOT_NOT_ELIGIBLE_S, ".+")) then
							return OrigErrHandler(self, event, err, ...) 
						end
					else
						return OrigErrHandler(self, event, err, ...) 
					end
				end

				-- Handle information messages
				if event == 'UI_INFO_MESSAGE'  then
					if LeaPlusLC["ShowQuestUpdates"] == "On" then
						return OrigErrHandler(self, event, err, ...)
					end
				end

			end)

		end

		----------------------------------------------------------------------
		--	Show vanity buttons (helm and cloak on character sheet)
		----------------------------------------------------------------------

		if LeaPlusLC["ShowVanityButtons"] == "On" then

			-- Create checkboxs
			local hbox = CreateFrame('CheckButton', nil, CharacterModelFrame, "OptionsCheckButtonTemplate")
			hbox:SetSize(24, 24)
			hbox.f = hbox:CreateFontString(nil, 'OVERLAY', "GameFontNormal")
			hbox.f:SetPoint("LEFT", 24, 0)

			local cbox = CreateFrame('CheckButton', nil, CharacterModelFrame, "OptionsCheckButtonTemplate")
			cbox:SetSize(24, 24)
			cbox.f = cbox:CreateFontString(nil, 'OVERLAY', "GameFontNormal")
			cbox.f:SetPoint("LEFT", 24, 0)

			-- Refresh checkbox state while controls are shown
			local htimer = 0
			local hshow, cshow, hchek, cchek

			hbox:SetScript('OnUpdate', function(self, elapsed)
				htimer = htimer + elapsed;
				while (htimer > 0.05) do
					-- Lock controls if player is dead
					if UnitIsDeadOrGhost("player") then
						LeaPlusLC:LockItem(hbox,true)
						LeaPlusLC:LockItem(cbox,true)
						return
					else
						LeaPlusLC:LockItem(hbox,false)
						LeaPlusLC:LockItem(cbox,false)
					end
					-- Get the checkbox states and the actual helm and cloak states
					hshow, cshow, hchek, cchek = ShowingHelm(), ShowingCloak(), hbox:GetChecked(), cbox:GetChecked()
					if hchek ~= hshow then
						-- Checkbox state doesn't match helm state so should be disabled while we wait for update
						if hbox:IsEnabled() then
							hbox:Disable()
						end
					else
						if not hbox:IsEnabled() then
							-- Checkbox matches helm state so should be enabled
							hbox:Enable()
						end
					end
					if cchek ~= cshow then
						-- Checkbox doesn't match cloak state so should be disabled while we wait for update
						if cbox:IsEnabled() then
							cbox:Disable()
						end
					else
						if not cbox:IsEnabled() then
							-- Checkbox matches cloak state so should be enabled
							cbox:Enable()
						end
					end
					-- Set the checkboxes to the actual helm and cloak states
					hbox:SetChecked(hshow);
					cbox:SetChecked(cshow);
					-- That was fun so let's do it again
					htimer = 0;
				end
			end)

			-- Positioning functions for dual layout
			local function SetVanityPlacement()
				if LeaPlusLC["ShowVanityInFrame"] == "On" then
					hbox:ClearAllPoints();
					hbox:SetPoint("TOPLEFT", 166, -326)
					hbox:SetHitRectInsets(0, -10, 0, 0);
					hbox.f:SetText("H");
					cbox:ClearAllPoints();
					cbox:SetPoint("TOPLEFT", 206, -326)
					cbox:SetHitRectInsets(0, -10, 0, 0);
					cbox.f:SetText("C");
				else
					hbox:ClearAllPoints();
					hbox:SetPoint("TOPLEFT", 4, -298)
					hbox:SetHitRectInsets(0, -32, 0, 0);
					hbox.f:SetText("Helm");
					cbox:ClearAllPoints();
					cbox:SetPoint("TOPLEFT", 164, -298)
					cbox:SetHitRectInsets(0, -36, 0, 0);
					cbox.f:SetText("Cloak");
				end
				hbox:SetAlpha(0.7);
				cbox:SetAlpha(0.7);
			end

			-- Click handlers
			hbox:SetScript('OnClick', function(self, btn)
				ShowHelm(hbox:GetChecked())
			end)

			cbox:SetScript('OnClick', function(self, btn)
				ShowCloak(cbox:GetChecked())
			end)

			hbox:SetScript('OnMouseDown', function(self, btn)
				if btn == "RightButton" and IsShiftKeyDown() then
					if LeaPlusLC["ShowVanityInFrame"] == "On" then LeaPlusLC["ShowVanityInFrame"] = "Off" else LeaPlusLC["ShowVanityInFrame"] = "On" end
					SetVanityPlacement();
				end
			end)

			cbox:SetScript('OnMouseDown', function(self, btn)
				if btn == "RightButton" and IsShiftKeyDown() then
					if LeaPlusLC["ShowVanityInFrame"] == "On" then LeaPlusLC["ShowVanityInFrame"] = "Off" else LeaPlusLC["ShowVanityInFrame"] = "On" end
					SetVanityPlacement();
				end
			end)

			-- Show checkboxes with character sheet
			CharacterModelFrame:HookScript("OnShow", SetVanityPlacement)

		end

		----------------------------------------------------------------------
		--	Show dressup buttons
		----------------------------------------------------------------------

		if LeaPlusLC["ShowDressTab"] == "On" then

			-- Add buttons to main dressup frame
			LeaPlusLC:CreateButton("DressUpTabBtn", DressUpFrame, "Tabard", "BOTTOMLEFT", 26, 79, 80, 22, false, "")
			LeaPlusCB["DressUpTabBtn"]:SetScript("OnClick", function()
				DressUpModel:UndressSlot(19)
			end)

			LeaPlusLC:CreateButton("DressUpNudeBtn", DressUpFrame, "Nude", "BOTTOMLEFT", 106, 79, 80, 22, false, "")
			LeaPlusCB["DressUpNudeBtn"]:SetScript("OnClick", function()
				DressUpFrameResetButton:Click() -- Done first in case any slots refuse to clear
				for i = 1, 19 do
					DressUpModel:UndressSlot(i) -- Done this way to prevent issues with Undress
				end
			end)

			local BtnStrata, BtnLevel = SideDressUpModelResetButton:GetFrameStrata(), SideDressUpModelResetButton:GetFrameLevel()

			-- Add buttons to dressup frame (auction house)
			LeaPlusLC:CreateButton("DressUpSideBtn", SideDressUpFrame, "Tabard", "BOTTOMLEFT", 14, 20, 60, 22, false, "")
			LeaPlusCB["DressUpSideBtn"]:SetFrameStrata(BtnStrata);
			LeaPlusCB["DressUpSideBtn"]:SetFrameLevel(BtnLevel);
			LeaPlusCB["DressUpSideBtn"]:SetScript("OnClick", function()
				SideDressUpModel:UndressSlot(19)
			end)

			LeaPlusLC:CreateButton("DressUpSideNudeBtn", SideDressUpFrame, "Nude", "BOTTOMRIGHT", -18, 20, 60, 22, false, "")
			LeaPlusCB["DressUpSideNudeBtn"]:SetFrameStrata(BtnStrata);
			LeaPlusCB["DressUpSideNudeBtn"]:SetFrameLevel(BtnLevel);
			LeaPlusCB["DressUpSideNudeBtn"]:SetScript("OnClick", function()
				SideDressUpModelResetButton:Click() -- Done first in case any slots refuse to clear
				for i = 1, 19 do
					SideDressUpModel:UndressSlot(i) -- Done this way to prevent issues with Undress
				end
			end)

		end

		----------------------------------------------------------------------
		--	Minimap button
		----------------------------------------------------------------------

		if LeaPlusLC["ShowMinimapIcon"] == "On" then
	
			-- Create minimap button
			local minibtn = CreateFrame("Button", "LeaPlusMapBtn", Minimap)
			LeaPlusCB["MiniMapButton"] = minibtn
			minibtn:SetSize(32,32)
			minibtn:SetMovable(true)
			minibtn:SetFrameStrata("MEDIUM")
			minibtn:SetNormalTexture("Interface/COMMON/Indicator-Green.png")
			minibtn:SetPushedTexture("Interface/COMMON/Indicator-Green.png")
			minibtn:SetHighlightTexture("Interface/COMMON/Indicator-Green.png")
			minibtn:RegisterForClicks("AnyUp")

			local function UpdateMapBtn()
				local Xpoa, Ypoa = GetCursorPosition()
				local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
				Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
				Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
				LeaPlusLC["MinimapIconPos"] = math.deg(math.atan2(Ypoa, Xpoa))
				minibtn:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", 52 - (80 * cos(LeaPlusLC["MinimapIconPos"])), (80 * sin(LeaPlusLC["MinimapIconPos"])) - 52)
			end

			-- Control movement
			minibtn:RegisterForDrag("LeftButton")
			minibtn:SetScript("OnDragStart", function()
				minibtn:StartMoving()
				minibtn:SetScript("OnUpdate", UpdateMapBtn)
			end)

			minibtn:SetScript("OnDragStop", function ()
				minibtn:StopMovingOrSizing();
				minibtn:SetUserPlaced(false);
				minibtn:SetScript("OnUpdate", nil)
				UpdateMapBtn();
			end)

			-- Set position
			minibtn:ClearAllPoints();
			minibtn:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(LeaPlusLC["MinimapIconPos"])),(80*sin(LeaPlusLC["MinimapIconPos"]))-52)

			-- Control clicks
			minibtn:SetScript("OnClick", function(self,arg1)
				-- Prevent options panel from showing if version panel or Blizzard options panel is showing
				if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then return end
				if LeaPlusLC["VersionPanel"] and LeaPlusLC["VersionPanel"]:IsShown() then return end
				-- Left button down
				if arg1 == "LeftButton" then

					-- Control key modifier toggles target tracking
					if IsControlKeyDown() and not IsShiftKeyDown() then
						for i = 1, GetNumTrackingTypes() do
							local name, texture, active, category = GetTrackingInfo(i)
							if name == MINIMAP_TRACKING_TARGET then
								if active == 1 then
									SetTracking(i, false)
									ActionStatus_DisplayMessage("Target Tracking Disabled", true);
								else
									SetTracking(i, true)
									ActionStatus_DisplayMessage("Target Tracking Enabled", true);
								end
							end
						end
						return
					end

					-- Shift key modifier toggles the music
					if IsShiftKeyDown() and not IsControlKeyDown() then
						Sound_ToggleMusic();
						return
					end

					-- Shift key and control key toggles Zygor addon
					if IsShiftKeyDown() and IsControlKeyDown() then
						LeaPlusLC:ZygorToggle();
						return
					end

					-- No modifier key toggles the options panel
					if LeaPlusLC["PageF"]:IsShown() then
						LeaPlusLC:HideFrames();
					else
						LeaPlusLC:HideFrames();
						LeaPlusLC["PageF"]:Show();
					end
					if LeaPlusLC["OpenPlusAtHome"] == "Off" then
						LeaPlusLC["Page"..LeaPlusLC["LeaStartPage"]]:Show()
					else
						LeaPlusLC["Page0"]:Show();
					end
				end

				-- Right button down
				if arg1 == "RightButton" then

					-- Control key modifier does nothing (yet)
					if IsControlKeyDown() and not IsShiftKeyDown() then
						return
					end

					-- Shift key modifier toggles coordinates
					if IsShiftKeyDown() and not IsControlKeyDown() then
						if LeaPlusLC["StaticCoordsEn"] == "On" then
							if LeaPlusLC["StaticCoords"] == "On" then
								LeaPlusLC["StaticCoords"] = "Off";
								ActionStatus_DisplayMessage("Coordinates Disabled", true);
							else
								LeaPlusLC["StaticCoords"] = "On";
								SetMapToCurrentZone();
								ActionStatus_DisplayMessage("Coordinates Enabled", true);
							end
							-- Run the coordinates refresh function
							LeaPlusLC:RefreshStaticCoords();
							-- Update side panel checkbox if it's showing
							if LeaPlusCB["StaticCoords"]:IsShown() then
								LeaPlusCB["StaticCoords"]:Hide();
								LeaPlusCB["StaticCoords"]:Show();
							end
						end
						return
					end

					-- Shift key and control key toggles maximised window mode
					if IsShiftKeyDown() and IsControlKeyDown() then
						if GetCVar("gxWindow") == "1" then
							if LeaPlusLC:PlayerInCombat() then
								return
							else
								SetCVar("gxMaximize", tostring(1 - GetCVar("gxMaximize")));
								RestartGx();
							end
						end
						return
					end

					-- No modifier key toggles error text
					if LeaPlusDB["HideErrorFrameText"] == "On" then -- Checks global
						if LeaPlusLC["ShowErrorsFlag"] == 1 then 
							LeaPlusLC["ShowErrorsFlag"] = 0
							minibtn:SetNormalTexture("Interface/COMMON/Indicator-Red.png")
							minibtn:SetPushedTexture("Interface/COMMON/Indicator-Red.png")
							minibtn:SetHighlightTexture("Interface/COMMON/Indicator-Red.png")
							ActionStatus_DisplayMessage("Error frame text will be shown", true);
						else
							LeaPlusLC["ShowErrorsFlag"] = 1
							minibtn:SetNormalTexture("Interface/COMMON/Indicator-Green.png")
							minibtn:SetPushedTexture("Interface/COMMON/Indicator-Green.png")
							minibtn:SetHighlightTexture("Interface/COMMON/Indicator-Green.png")
							ActionStatus_DisplayMessage("Error frame text will be hidden", true);
						end
						return
					end
				end

				-- Middle button modifier
				if arg1 == "MiddleButton" then
					-- Nothing (yet)
				end
			end)

		end

		----------------------------------------------------------------------
		-- L32: Tooltip customisation
		----------------------------------------------------------------------

		if LeaPlusLC["TipModEnable"] == "On" then

			local LT = {}

			-- Create locale specific level string
			LT["LevelLocale"] = strtrim(strtrim(string.gsub(TOOLTIP_UNIT_LEVEL, "%%s", "")))

			-- Tooltip
			LT["ColorBlind"] = GetCVar("colorblindMode")

			-- 	Create drag frame
			local TipDrag = CreateFrame("Frame", nil, UIParent)
			TipDrag:SetMovable(true)
			TipDrag:EnableMouse(true)
			TipDrag:RegisterForDrag("LeftButton")
			TipDrag:SetToplevel(true);
			TipDrag:SetClampedToScreen();
			TipDrag:SetSize(130, 64);
			TipDrag:Hide();
			TipDrag:SetFrameStrata("TOOLTIP")
			TipDrag:SetBackdropColor(0.0, 0.5, 1.0);
			TipDrag:SetBackdrop({ 
				edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
				tile = false, tileSize = 0, edgeSize = 16,
				insets = { left = 0, right = 0, top = 0, bottom = 0 }});

			-- Show text in drag frame
			TipDrag.f = TipDrag:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
			TipDrag.f:SetPoint('TOPLEFT', 16, -16)
			TipDrag.f:SetText("Tooltip")

			-- Create texture
			TipDrag.t = TipDrag:CreateTexture();
			TipDrag.t:SetAllPoints();
			TipDrag.t:SetTexture(0.0, 0.5, 1.0, 0.5);
			TipDrag.t:SetAlpha(0.5);

			---------------------------------------------------------------------------------------------------------
			-- Tooltip movement settings
			---------------------------------------------------------------------------------------------------------

			-- Create tooltip customisation side panel
			local SideTip = LeaPlusLC:CreateSidePanel("Tooltip", 164, 280)

			-- Add controls
			LeaPlusLC:MakeTx(SideTip, "Settings", 10, -60)
			LeaPlusLC:MakeCB(SideTip, "TipShowTitle"	, 	"Show title"		, 	10, -80, 	"If checked, player titles will be shown.", 2)
			LeaPlusLC:MakeCB(SideTip, "TipShowRank"		, 	"Show rank"			, 	10, -100, 	"If checked, guild ranks will be shown for players in your guild.", 2)
			LeaPlusLC:MakeCB(SideTip, "TipShowTarget"	, 	"Show target"		, 	10, -120, 	"If checked, unit targets will be shown.", 2)
			LeaPlusLC:MakeCB(SideTip, "TipBackSimple"	, 	"Color backdrops"	,	10, -140, 	"If checked, backdrops will be tinted blue (friendly) or red (hostile).", 2)

			LeaPlusLC:MakeTx(SideTip, "Scale", 10, -180)
			LeaPlusLC:MakeSL(SideTip, "LeaPlusTipSize", "", 0.50, 3.00, 0.05, 10, -200, "%.2f")

			-- Create save button
			LeaPlusLC:CreateButton("SaveTipBtn", SideTip, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
			LeaPlusCB["SaveTipBtn"]:SetScript("OnClick", function()
				SideTip:Hide();
				if TipDrag:IsShown() then
					TipDrag:Hide();
				end
				LeaPlusLC["PageF"]:Show();
				LeaPlusLC["Page6"]:Show();
				return
			end)

			-- Create reset button
			LeaPlusLC:CreateButton("ResetTipBtn", SideTip, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
			LeaPlusCB["ResetTipBtn"]:SetScript("OnClick", function()
				LeaPlusLC["TipShowTitle"] = "On";
				LeaPlusLC["TipShowRank"] = "On";
				LeaPlusLC["TipShowTarget"] = "On";
				LeaPlusLC["TipBackSimple"] = "Off";
				LeaPlusLC["LeaPlusTipSize"] = 1.00
				LeaPlusLC["TipPosXOffset"] = -13
				LeaPlusLC["TipPosYOffset"] = 94
				LeaPlusLC["TipPosAnchor"] = "BOTTOMRIGHT";
				LeaPlusLC["TipPosRelative"] = "BOTTOMRIGHT";	
				TipDrag:ClearAllPoints();
				TipDrag:SetPoint(LeaPlusLC["TipPosAnchor"], UIParent, LeaPlusLC["TipPosRelative"], LeaPlusLC["TipPosXOffset"], LeaPlusLC["TipPosYOffset"]);
				LeaPlusLC:SetTipScale()
				SideTip:Hide(); SideTip:Show();
			end)

			-- Control movement functions
			TipDrag:SetScript("OnDragStart", TipDrag.StartMoving)
			TipDrag:SetScript("OnDragStop", function ()
				TipDrag:StopMovingOrSizing();
				LeaPlusLC["TipPosAnchor"], LeaPlusLC["LpTipRelaAnchor"], LeaPlusLC["TipPosRelative"], LeaPlusLC["TipPosXOffset"], LeaPlusLC["TipPosYOffset"] = TipDrag:GetPoint()
			end)

			--	Move the tooltip
			LeaPlusCB["MoveTooltipButton"]:SetScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Private profile
					LeaPlusLC["TipShowTitle"] = "On";
					LeaPlusLC["TipShowRank"] = "On";
					LeaPlusLC["TipShowTarget"] = "On";
					LeaPlusLC["TipBackSimple"] = "On";
					LeaPlusLC["TipAnchorToMouse"] = "Off";
					LeaPlusLC["LeaPlusTipSize"] = 1.25
					LeaPlusLC["TipPosXOffset"] = -13
					LeaPlusLC["TipPosYOffset"] = 94
					LeaPlusLC["TipPosAnchor"] = "BOTTOMRIGHT";
					LeaPlusLC["TipPosRelative"] = "BOTTOMRIGHT";
					TipDrag:ClearAllPoints();
					TipDrag:SetPoint(LeaPlusLC["TipPosAnchor"], UIParent, LeaPlusLC["TipPosRelative"], LeaPlusLC["TipPosXOffset"], LeaPlusLC["TipPosYOffset"]);
					LeaPlusLC:SetTipScale()
					LeaPlusLC:SetDim();
					LeaPlusLC:ReloadCheck();
					LeaPlusLC["PageF"]:Hide(); LeaPlusLC["PageF"]:Show();
				else
					-- Show tooltip movement frame
					LeaPlusLC:HideFrames();
					SideTip:Show();
					if TipDrag:IsShown() then
						SideTip:Hide();
						TipDrag:Hide();
						return
					else
						TipDrag:Show();
					end

					-- Set scale
					TipDrag:SetScale(LeaPlusLC["LeaPlusTipSize"])

					-- Set position of the drag frame
					TipDrag:ClearAllPoints();
					TipDrag:SetPoint(LeaPlusLC["TipPosAnchor"], UIParent, LeaPlusLC["TipPosRelative"], LeaPlusLC["TipPosXOffset"], LeaPlusLC["TipPosYOffset"]);
				end			

			end)
					
			---------------------------------------------------------------------------------------------------------
			-- Tooltip scale settings
			---------------------------------------------------------------------------------------------------------

			-- Function to set the tooltip scale
			local function SetTipScale()
				if LeaPlusLC["TipModEnable"] == "On" then
					-- General tooltip
					GameTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					-- Item tooltip (links in caht)
					ItemRefTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					-- Pet battle tooltips
					PetBattlePrimaryAbilityTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					PetBattlePrimaryUnitTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
					-- Tooltip overlay (when moving tooltip)
					TipDrag:SetScale(LeaPlusLC["LeaPlusTipSize"])
					FloatingBattlePetTooltip:SetScale(LeaPlusLC["LeaPlusTipSize"])
				end
				return
			end

			-- Give function a file level scope
			LeaPlusLC.SetTipScale = SetTipScale

			-- Set tooltip scale on startup
			SetTipScale();

			-- Set tooltip scale when slider or checkbox changes
			LeaPlusCB["LeaPlusTipSize"]:HookScript("OnValueChanged", SetTipScale);

			---------------------------------------------------------------------------------------------------------
			-- Anchor to Mouse Settings
			---------------------------------------------------------------------------------------------------------

			-- Create anchor to mouse pointer settings frame
			local SideAnchor = LeaPlusLC:CreateSidePanel("Anchor to Mouse", 164, 370)

			-- Create save button
			LeaPlusLC:CreateButton("SaveTipMouseBtn", SideAnchor, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
			LeaPlusCB["SaveTipMouseBtn"]:SetScript("OnClick", function()
				LeaPlusCB["ListFrameTipMouseAnchor"]:Hide(); -- Hide the dropdown list
				SideAnchor:Hide();
				LeaPlusLC["PageF"]:Show();
				LeaPlusLC["Page6"]:Show();
				return
			end)

			-- Create reset button
			LeaPlusLC:CreateButton("ResetTipMouseBtn", SideAnchor, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
			LeaPlusCB["ResetTipMouseBtn"]:SetScript("OnClick", function()
				LeaPlusCB["ListFrameTipMouseAnchor"]:Hide(); -- Hide the dropdown list
				LeaPlusLC["TipMouseAnchor"] = 4
				LeaPlusLC["TipMouseOffsetX"] = 0
				LeaPlusLC["TipMouseOffsetY"] = -120
				LeaPlusLC["TipAlpha"] = 1.0
				LeaPlusLC["TipHideCombat"] = "Off";
				SideAnchor:Hide(); SideAnchor:Show();
			end)

			LeaPlusLC:CreateDropDown("TipMouseAnchor", "Anchor", SideAnchor, 146, "TOPLEFT", 10, -100, {"BOTTOMLEFT", "LEFT", "TOPLEFT", "TOP", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT", "BOTTOM", "CENTER"}, "")

			-- Create slider controls
			LeaPlusLC:MakeTx(SideAnchor, "X Offset", 10, -120)
			LeaPlusLC:MakeSL(SideAnchor, "TipMouseOffsetX", "", -400, 400, 5, 10, -140, "%.0f")
			LeaPlusLC:MakeTx(SideAnchor, "Y Offset", 10, -170)
			LeaPlusLC:MakeSL(SideAnchor, "TipMouseOffsetY", "", -400, 400, 5, 10, -190, "%.0f")
			LeaPlusLC:MakeTx(SideAnchor, "Alpha", 10, -220)
			LeaPlusLC:MakeSL(SideAnchor, "TipAlpha", "", 0, 1, 0.1, 10, -240, "%.1f")
			LeaPlusLC:MakeCB(SideAnchor, "TipHideCombat", "Hide tips in combat", 10, -280, "If checked, tooltips in the game world will be hidden during combat.\n\nHold down the SHIFT key to temporarily show tooltips during combat.\n\nThis setting has no effect on tooltips outside of the game world (such as UI elements).", 2)

			-- Modify the anchor to mouse pointer settings
			LeaPlusCB["ModTipMouseBtn"]:SetScript("OnClick", function()
				LeaPlusLC:HideFrames();
				SideAnchor:Show();
			end)

			---------------------------------------------------------------------------------------------------------
			-- Other tooltip code
			---------------------------------------------------------------------------------------------------------

			-- Colorblind setting change
			TipDrag:RegisterEvent("CVAR_UPDATE");
			TipDrag:SetScript("OnEvent", function(self, event, arg1, arg2)
				if (arg1 == "USE_COLORBLIND_MODE") then
					LT["ColorBlind"] = arg2;
				end
			end)

			-- Store local copies of global class color tables
			local TipMClass = LOCALIZED_CLASS_NAMES_MALE
			local TipFClass = LOCALIZED_CLASS_NAMES_FEMALE

			--	Show tooltip
			local function ShowTip()

				-- Do nothing if CTRL, SHIFT and ALT are being held
				if IsControlKeyDown() then
					if IsAltKeyDown() and IsShiftKeyDown() then 
						GameTooltip:Show()
						return
					end
				end

				-- Get unit information
				if GetMouseFocus() == WorldFrame then
					LT["Unit"] = "mouseover"
				else
					LT["Unit"] = select(2, GameTooltip:GetUnit())
					if not (LT["Unit"]) then return end
				end

				-- Quit if unit has no reaction to player
				LT["Reaction"] = UnitReaction(LT["Unit"], "player") or nil
				if not LT["Reaction"] then 
					return
				end

				-- Setup variables
				LT["TipUnitName"], LT["TipUnitRealm"] = UnitName(LT["Unit"])
				LT["TipIsPlayer"] = UnitIsPlayer(LT["Unit"])
				LT["UnitLevel"] = UnitLevel(LT["Unit"])
				LT["UnitClass"] = select(2, UnitClassBase(LT["Unit"]))
				LT["PlayerControl"] = UnitPlayerControlled(LT["Unit"])
				LT["PlayerRace"] = UnitRace(LT["Unit"])

				-- Get guild information
				if LT["TipIsPlayer"] then
					if GetGuildInfo(LT["Unit"]) then
						-- Unit is guilded
						if LT["ColorBlind"] == "1" then
							LT["GuildLine"], LT["InfoLine"] = 2, 4
						else
							LT["GuildLine"], LT["InfoLine"] = 2, 3
						end
						LT["GuildName"], LT["GuildRank"] = GetGuildInfo(LT["Unit"])
					else
						-- Unit is not guilded
						LT["GuildName"] = nil
						if LT["ColorBlind"] == "1" then
							LT["GuildLine"], LT["InfoLine"] = 0, 3
						else
							LT["GuildLine"], LT["InfoLine"] = 0, 2
						end
					end
				end

				-- Determine class color
				if LT["UnitClass"] then
					-- Define male or female (for certain locales)
					LT["Sex"] = UnitSex(LT["Unit"])
					if LT["Sex"] == 2 then
						LT["Class"] = TipMClass[LT["UnitClass"]]
					else
						LT["Class"] = TipFClass[LT["UnitClass"]]
					end
					-- Define class color
					LT["ClassCol"] = LeaPlusLC["RaidColors"][LT["UnitClass"]]
					LT["LpTipClassColor"] = "|cff" .. string.format("%02x%02x%02x", LT["ClassCol"].r * 255, LT["ClassCol"].g * 255, LT["ClassCol"].b * 255)
				end

				----------------------------------------------------------------------
				-- Name line
				----------------------------------------------------------------------

				if ((LT["TipIsPlayer"]) or (LT["PlayerControl"])) or LT["Reaction"] > 4 then

					-- If it's a player show name in class color
					if LT["TipIsPlayer"] then
						LT["NameColor"] = LT["LpTipClassColor"]
					else
						-- If not, set to green or blue depending on PvP status
						if UnitIsPVP(LT["Unit"]) then
							LT["NameColor"] = "|cff00ff00"
						else
							LT["NameColor"] = "|cff00aaff"
						end
					end

					-- Show title
					if LeaPlusLC["TipShowTitle"] == "On" then
						LT["NameText"] = UnitPVPName(LT["Unit"])
					else
						LT["NameText"] = LT["TipUnitName"]
					end

					-- Show realm
					if LT["TipUnitRealm"] then
						LT["NameText"] = LT["NameText"] .. " - " .. LT["TipUnitRealm"]
					end

					-- Show dead units in grey
					if UnitIsDeadOrGhost(LT["Unit"]) then
						LT["NameColor"] = "|c88888888"
					end

					-- Show name line
					_G["GameTooltipTextLeft1"]:SetText(LT["NameColor"] .. LT["NameText"] .. "|cffffffff|r")
					
				elseif UnitIsDeadOrGhost(LT["Unit"]) then

					-- Show grey name for other dead units
					_G["GameTooltipTextLeft1"]:SetText("|c88888888" .. _G["GameTooltipTextLeft1"]:GetText() .. "|cffffffff|r")
					return

				end

				----------------------------------------------------------------------
				-- Guild line
				----------------------------------------------------------------------

				if LT["TipIsPlayer"] and LT["GuildName"] then
					
					-- Show guild line
					if LeaPlusLC["TipShowRank"] == "On" then
						if UnitIsInMyGuild(LT["Unit"]) then
							_G["GameTooltipTextLeft" .. LT["GuildLine"]]:SetText("|c00aaaaff" .. LT["GuildName"] .. " - " .. LT["GuildRank"] .. "|r")
						else
							_G["GameTooltipTextLeft" .. LT["GuildLine"]]:SetText("|c00aaaaff" .. LT["GuildName"] .. "|cffffffff|r")
						end
					else
						_G["GameTooltipTextLeft" .. LT["GuildLine"]]:SetText("|c00aaaaff" .. LT["GuildName"] .. "|cffffffff|r")
					end

				end

				----------------------------------------------------------------------
				-- Information line (level, class, race)
				----------------------------------------------------------------------

				if LT["TipIsPlayer"] then

					-- Show level
					if LT["Reaction"] < 5 then
						if LT["UnitLevel"] == -1 then
							LT["InfoText"] = ("|cffff3333Level ??|cffffffff")
						else
							LT["LevelColor"] = GetQuestDifficultyColor(UnitLevel(LT["Unit"]))
							LT["LevelColor"] = string.format('%02x%02x%02x', LT["LevelColor"].r * 255, LT["LevelColor"].g * 255, LT["LevelColor"].b * 255)
							LT["InfoText"] = ("|cff" .. LT["LevelColor"] .. LT["LevelLocale"] .. " " .. LT["UnitLevel"] .. "|cffffffff")
						end
					else
						LT["InfoText"] = LT["LevelLocale"] .. " " .. LT["UnitLevel"]
					end

					-- Show race
					if LT["PlayerRace"] then
						LT["InfoText"] = LT["InfoText"] .. " " .. LT["PlayerRace"]
					end

					-- Show class
					LT["InfoText"] = LT["InfoText"] .. " " .. LT["LpTipClassColor"] .. LT["Class"] or LT["InfoText"]

					-- Show information line
					_G["GameTooltipTextLeft" .. LT["InfoLine"]]:SetText(LT["InfoText"] .. "|cffffffff|r")

				end

				----------------------------------------------------------------------
				-- Mob name in brighter red (alive) and steel blue (tapped)
				----------------------------------------------------------------------

				if not (LT["TipIsPlayer"]) and LT["Reaction"] < 4 and not (LT["PlayerControl"]) then
					if (UnitIsTapped(LT["Unit"]) and not (UnitIsTappedByPlayer(LT["Unit"]))) then
						LT["NameText"] = "|c8888bbbb" .. LT["TipUnitName"] .. "|r"
					else
						LT["NameText"] = "|cffff3333" .. LT["TipUnitName"] .. "|r"
					end
					_G["GameTooltipTextLeft1"]:SetText(LT["NameText"])
				end

				----------------------------------------------------------------------
				-- Mob level in color (neutral or lower)
				----------------------------------------------------------------------

				if not (LT["TipIsPlayer"]) and LT["Reaction"] < 5 and not (LT["PlayerControl"]) then

					-- Level ?? mob
					if LT["UnitLevel"] == -1 then
						LT["InfoText"] = "|cffff3333Level ??|cffffffff "

					-- Mobs within level range
					else
						LT["MobColor"] = (GetQuestDifficultyColor(UnitLevel(LT["Unit"])))
						LT["MobColor"] = string.format('%02x%02x%02x', LT["MobColor"].r * 255, LT["MobColor"].g * 255, LT["MobColor"].b * 255)
						LT["InfoText"] = "|cff" .. LT["MobColor"] .. LT["LevelLocale"] .. " " .. LT["UnitLevel"] .. "|cffffffff "
					end

					-- Find the line with level information on it
					if (_G["GameTooltipTextLeft2"]:GetText()) == nil then
						LT["MobInfoLine"] = 2 
					else
						if not (strsplit(" ", (_G["GameTooltipTextLeft2"]:GetText()),2) == LT["LevelLocale"]) then LT["MobInfoLine"] = 3 else LT["MobInfoLine"] = 2 end
					end

					-- Show creature type and classification
					LT["CreatureType"] = UnitCreatureType(LT["Unit"])
					if (LT["CreatureType"]) and not (LT["CreatureType"] == "Not specified") then
						LT["InfoText"] = LT["InfoText"] .. "|cffffffff" .. LT["CreatureType"] .. "|cffffffff "
					end

					-- Rare, elite and boss mobs
					LT["Special"] = UnitClassification(LT["Unit"])
					if LT["Special"] then
						if LT["Special"] == "elite" then 
							LT["Special"] = "(Elite)"
						elseif LT["Special"] == "rare" then 
							LT["Special"] = "|c00e066ff(Rare)"
						elseif LT["Special"] == "rareelite" then
							LT["Special"] = "|c00e066ff(Rare Elite)"
						elseif LT["Special"] == "worldboss" then 
							LT["Special"] = "(Boss)"
						else LT["Special"] = nil 
						end

						if (LT["Special"]) then
							LT["InfoText"] = LT["InfoText"] .. LT["Special"]
						end
					end

					-- Wild battle pets (show collected data)
					if UnitIsWildBattlePet(LT["Unit"]) then 
						LT["InfoText"] = GameTooltipTextLeft3:GetText()
					end

					-- Show mob info line
					_G["GameTooltipTextLeft" .. LT["MobInfoLine"]]:SetText(LT["InfoText"])

				end

				----------------------------------------------------------------------
				-- Backdrop color
				----------------------------------------------------------------------

				LT["TipFaction"] = UnitFactionGroup(LT["Unit"])

				if UnitCanAttack("player", LT["Unit"]) and not (UnitIsDeadOrGhost(LT["Unit"])) and not (LT["TipFaction"] == nil) and not (LT["TipFaction"] == UnitFactionGroup("player")) then
					-- Hostile faction
					if LeaPlusLC["TipBackSimple"] == "On" then
						GameTooltip:SetBackdropColor(0.5, 0.0, 0.0);
					else
						GameTooltip:SetBackdropColor(0.0, 0.0, 0.0);
					end
				else
					-- Friendly faction
					if LeaPlusLC["TipBackSimple"] == "On" then
						GameTooltip:SetBackdropColor(0.0, 0.0, 0.5);
					else
						GameTooltip:SetBackdropColor(0.0, 0.0, 0.0);
					end
				end

				----------------------------------------------------------------------
				--	Show target
				----------------------------------------------------------------------

				if LeaPlusLC["TipShowTarget"] == "On" then

					-- Get target
					LT["Target"] = UnitName(LT["Unit"] .. "target");

					-- If target doesn't exist, quit
					if LT["Target"] == nil or LT["Target"] == "" then return end

					-- If target is you, set target to YOU
					if (UnitIsUnit(LT["Target"], "player")) then 
						LT["Target"] = ("|c12ff4400YOU")

					-- If it's not you, but it's a player, show target in class color
					elseif UnitIsPlayer(LT["Unit"] .. "target") then
						LT["TargetBase"] = select(2, UnitClassBase(LT["Unit"] .. "target"))
						LT["TargetCol"] = LeaPlusLC["RaidColors"][LT["TargetBase"]]
						LT["TargetCol"] = "|cff" .. string.format('%02x%02x%02x', LT["TargetCol"].r * 255, LT["TargetCol"].g * 255, LT["TargetCol"].b * 255)
						LT["Target"] = (LT["TargetCol"] .. LT["Target"])

					end
					
					-- Add target line
					GameTooltip:AddLine("Target: " .. LT["Target"])

				end

			end

			GameTooltip:HookScript("OnTooltipSetUnit", ShowTip)
			
		end

		-- Release memory
		LeaPlusLC.Isolated = nil

	end

----------------------------------------------------------------------
--	L40: Variable
----------------------------------------------------------------------

	function LeaPlusLC:Variable()

		----------------------------------------------------------------------
		-- Map customisation
		----------------------------------------------------------------------

		if LeaPlusLC["ShowMapMod"] == "On" then

			----------------------------------------------------------------------
			-- Basic modification
			----------------------------------------------------------------------

			-- Function to toggle the world map safely without tainting
			local function ToggleMapSafe()
				local sfx = GetCVar("Sound_EnableSFX");
				SetCVar("Sound_EnableSFX", 0);
				MiniMapWorldMapButton:Click(); MiniMapWorldMapButton:Click();
				SetCVar("Sound_EnableSFX", sfx);
			end

			-- Enable mousewheel for traversing map floors
			WorldMapButton:SetScript("OnMouseWheel", function(self, delta)
				local newLevel = GetCurrentMapDungeonLevel() - delta
				if newLevel >= 1 and newLevel <= GetNumDungeonMapLevels() then
					SetDungeonMapLevel(newLevel)
					PlaySound("UChatScrollButton")
				end
			end)

			-- Make character location pointer non-interactive (else the name tooltip gets in the way)
			WorldMapPlayerUpper:EnableMouse(false);
			WorldMapPlayerLower:EnableMouse(false);

			----------------------------------------------------------------------
			-- Map reveal (why isn't there a CVAR for this?)
			----------------------------------------------------------------------

			--local mapcrawler = 423582990616; print(mapcrawler % 1024, floor(mapcrawler / 1024) % 1024, floor(mapcrawler / 1048576) % 1024, floor(mapcrawler / 1073741824))

			local LeaPlusMapData = {

				-- Eastern Kingdoms
				["Arathi"] = {"CirecleofOuterBinding:215:188:332:273", "CircleofWestBinding:220:287:85:24", "NorthfoldManor:227:268:132:105", "Bouldergor:249:278:171:123", "StromgardeKeep:284:306:21:269", "FaldirsCove:273:268:77:400", "CircleofInnerBinding:228:227:201:312", "ThandolSpan:237:252:261:416", "BoulderfistHall:252:258:327:367", "RefugePoint:196:270:293:145", "WitherbarkVillage:260:220:476:359", "GoShekFarm:306:248:430:249", "DabyriesFarmstead:210:227:404:144", "CircleofEastBinding:183:238:506:126", "Hammerfall:270:271:581:118", "GalensFall:212:305:0:144"},
				["Badlands"] = {"AgmondsEnd:342:353:230:315", "AngorFortress:285:223:230:68", "ApocryphansRest:252:353:0:66", "CampBoff:274:448:407:220", "CampCagg:339:347:0:281", "CampKosh:236:260:504:19", "DeathwingScar:328:313:175:178", "HammertoesDigsite:209:196:411:116", "LethlorRavine:469:613:533:55", "TheDustbowl:214:285:144:99", "Uldaman:266:210:336:0",},
				["BlastedLands"] = {"AltarofStorms:238:195:225:110", "DreadmaulHold:272:206:258:0", "DreadmaulPost:235:188:327:182", "NethergardeKeep:295:205:530:6", "NethergardeSupplyCamps:195:199:436:0", "RiseoftheDefiler:168:170:375:102", "SerpentsCoil:218:183:459:97", "Shattershore:240:270:578:91", "SunveilExcursion:233:266:386:374", "Surwich:199:191:333:474", "TheDarkPortal:370:298:368:179", "TheRedReaches:268:354:533:268", "TheTaintedForest:348:357:132:311", "TheTaintedScar:308:226:144:175",},
				["BurningSteppes"] = {"AltarofStorms:182:360:0:0", "BlackrockMountain:281:388:79:0", "BlackrockPass:298:410:419:258", "BlackrockStronghold:320:385:235:0", "Dracodar:362:431:0:237", "DreadmaulRock:274:263:568:151", "MorgansVigil:383:413:615:255", "PillarofAsh:274:413:253:255", "RuinsofThaurissan:324:354:421:0", "TerrorWingPath:350:341:646:7",},
				["Darkshore"] = {"AmethAran:326:145:294:330", "EyeoftheVortex:330:192:300:239", "Lordanel:277:281:391:54", "Nazjvel:244:201:207:467", "RuinsofAuberdine:203:194:280:182", "RuinsofMathystra:200:263:517:28", "ShatterspearVale:250:241:596:16", "ShatterspearWarcamp:245:147:565:0", "TheMastersGlaive:303:185:277:483", "WildbendRiver:314:193:280:378", "WitheringThicket:328:250:305:118",},
				["DeadwindPass"] = {"DeadmansCrossing:617:522:83:0", "Karazhan:513:358:92:310", "TheVice:350:449:433:208",},
				["DunMorogh"] = {"AmberstillRanch:249:183:595:225", "ColdridgePass:225:276:360:340", "ColdridgeValley:398:302:100:366", "FrostmaneFront:226:335:469:256", "FrostmaneHold:437:249:50:227", "Gnomeregan:409:318:0:27", "GolBolarQuarry:198:251:663:288", "HelmsBedLake:218:234:760:268", "IceFlowLake:236:358:263:0", "Ironforge:376:347:398:0", "IronforgeAirfield:308:335:630:0", "Kharanos:184:188:449:220", "NorthGateOutpost:237:366:765:43", "TheGrizzledDen:211:160:374:287", "TheShimmeringDeep:171:234:397:132", "TheTundridHills:174:249:579:306",},
				["Duskwood"] = {"AddlesStead:299:296:32:348", "BrightwoodGrove:279:399:497:112", "Darkshire:329:314:640:128", "ManorMistmantle:219:182:661:122", "RacenHill:205:157:96:292", "RavenHillCemetary:323:309:91:132", "TheDarkenedBank:931:235:71:26", "TheHushedBank:189:307:0:152", "TheRottingOrchard:291:263:539:368", "TheTranquilGardensCemetary:291:244:627:344", "TheTwilightGrove:320:388:314:101", "TheYorgenFarmstead:233:248:401:396", "VulGolOgreMound:268:282:228:355",},
				["EasternPlaguelands"] = {"Acherus:228:273:774:102", "BlackwoodLake:238:231:382:151", "CorinsCrossing:186:213:493:289", "CrownGuardTower:202:191:258:351", "Darrowshire:248:206:211:462", "EastwallTower:181:176:541:184", "LakeMereldar:266:241:462:427", "LightsHopeChapel:196:220:687:271", "LightsShieldTower:243:162:391:271", "Northdale:265:232:570:61", "NorthpassTower:250:192:401:69", "Plaguewood:328:253:144:40", "QuelLithienLodge:277:175:351:0", "RuinsOfTheScarletEnclave:264:373:738:295", "Stratholme:310:178:118:0", "Terrordale:258:320:0:10", "TheFungalVale:274:216:183:211", "TheInfectisScar:177:266:595:263", "TheMarrisStead:202:202:133:335", "TheNoxiousGlade:297:299:650:55", "ThePestilentScar:182:320:383:348", "TheUndercroft:280:211:56:457", "ThondorilRiver:262:526:0:100", "Tyrshand:214:254:651:414", "ZulMashar:286:176:528:0",},
				["Elwynn"] = {"BrackwellPumpkinPatch:287:216:532:424", "CrystalLake:220:207:417:327", "EastvaleLoggingCamp:294:243:703:292", "FargodeepMine:269:248:240:420", "Goldshire:276:231:247:294", "JerodsLanding:230:206:396:430", "NorthshireValley:295:296:355:138", "RidgepointTower:285:194:708:442", "StonecairnLake:340:272:552:186", "Stromwind:512:422:0:0", "TowerofAzora:270:241:529:287", "WestbrookGarrison:269:313:116:355",},
				["Ghostlands"] = {"AmaniPass:404:436:598:232", "BleedingZiggurat:256:256:184:238", "DawnstarSpire:427:256:575:0", "Deatholme:512:293:95:375", "ElrendarCrossing:512:256:326:0", "FarstriderEnclave:429:256:573:136", "GoldenmistVillage:512:512:44:0", "HowlingZiggurat:256:449:340:219", "IsleofTribulations:256:256:585:0", "SanctumoftheMoon:256:256:210:126", "SanctumoftheSun:256:512:448:150", "SuncrownVillage:512:256:460:0", "ThalassiaPass:256:262:364:406", "Tranquillien:256:512:365:2", "WindrunnerSpire:256:256:40:287", "WindrunnerVillage:256:512:60:117", "ZebNowa:512:431:466:237",},
				["HillsbradFoothills"] = {"AzurelodeMine:180:182:287:399", "ChillwindPoint:447:263:555:68", "CorrahnsDagger:135:160:426:224", "CrushridgeHold:134:124:463:101", "DalaranCrater:316:238:102:137", "DandredsFold:258:113:341:0", "DarrowHill:147:160:425:279", "DunGarok:269:258:542:410", "DurnholdeKeep:437:451:565:217", "GallowsCorner:155:147:451:140", "GavinsNaze:116:129:344:254", "GrowlessCave:171:136:359:191", "HillsbradFields:302:175:191:302", "LordamereInternmentCamp:250:167:194:216", "MistyShore:158:169:321:42", "NethanderSteed:204:244:502:373", "PurgationIsle:144:139:200:505", "RuinsOfAlterac:189:181:347:85", "SlaughterHollow:148:120:413:55", "SoferasNaze:148:146:484:166", "SouthpointTower:312:254:59:310", "Southshore:229:219:383:352", "Strahnbrad:275:193:505:44", "TarrenMill:165:203:494:226", "TheHeadland:105:148:390:255", "TheUplands:212:160:441:0",},
				["Hinterlands"] = {"AeriePeak:238:267:0:236", "Agolwatha:208:204:367:159", "JinthaAlor:287:289:487:334", "PlaguemistRavine:191:278:133:105", "QuelDanilLodge:241:211:220:181", "Seradane:303:311:475:5", "ShadraAlor:240:196:220:379", "Shaolwatha:281:261:565:208", "SkulkRock:176:235:490:195", "TheAltarofZul:225:196:357:343", "TheCreepingRuin:199:199:390:252", "TheOverlookCliffs:244:401:677:267", "ValorwindLake:199:212:286:269", "Zunwatha:226:225:152:284",},
				["LochModan"] = {"GrizzlepawRidge:273:230:245:324", "IronbandsExcavationSite:397:291:481:296", "MogroshStronghold:294:249:549:52", "NorthgatePass:319:289:16:0", "SilverStreamMine:225:252:221:0", "StonesplinterValley:273:294:177:345", "StronewroughtDam:333:200:339:0", "TheFarstriderLodge:349:292:570:209", "TheLoch:330:474:340:81", "Thelsamar:455:295:0:146", "ValleyofKings:310:345:0:311",},
				["Redridge"] = {"AlthersMill:228:247:350:139", "CampEverstill:189:193:445:286", "GalardellValley:428:463:574:0", "LakeEverstill:464:250:81:214", "LakeridgeHighway:392:352:148:316", "Lakeshire:410:256:0:110", "RedridgeCanyons:413:292:37:0", "RendersCamp:357:246:214:0", "RendersValley:427:291:451:377", "ShalewindCanyon:306:324:688:283", "StonewatchFalls:316:182:525:302", "StonewatchKeep:228:420:480:0", "ThreeCorners:323:406:0:256",},
				["RuinsofGilneas"] = {"GilneasPuzzle:1002:668:0:0",},
				["Gilneas"] = {"NorthgateWoods:282:298:482:14", "GilneasCity:282:263:483:210", "StormglenVillage:321:203:516:465", "HammondFarmstead:194:236:167:352", "HaywardFishery:177:219:293:449", "TempestsReach:350:345:652:290", "TheHeadlands:328:336:160:0", "Duskhaven:286:178:272:333", "NorthernHeadlands:267:314:387:0", "Keelharbor:280:342:298:95", "CrowleyOrchard:210:166:261:427", "EmberstoneMine:281:351:639:43", "Greymanemanor:244:241:141:202", "KorothsDen:222:268:393:386", "TheBlackwald:280:224:504:394",},
				["Gilneas_terrain1"] = {"NorthgateWoods:282:298:482:14", "GilneasCity:282:263:483:210", "StormglenVillage:321:203:516:465", "HammondFarmstead:194:236:167:352", "HaywardFishery:177:219:293:449", "TempestsReach:350:345:652:290", "TheHeadlands:328:336:160:0", "Duskhaven:286:178:272:333", "NorthernHeadlands:267:314:387:0", "Keelharbor:280:342:298:95", "CrowleyOrchard:210:166:261:427", "EmberstoneMine:281:351:639:43", "Greymanemanor:244:241:141:202", "KorothsDen:222:268:393:386", "TheBlackwald:280:224:504:394",},
				["Gilneas_terrain2"] = {"NorthgateWoods:282:298:482:14", "GilneasCity:282:263:483:210", "StormglenVillage:321:203:516:465", "HammondFarmstead:194:236:167:352", "HaywardFishery:177:219:293:449", "TempestsReach:350:345:652:290", "TheHeadlands:328:336:160:0", "Duskhaven:286:178:272:333", "NorthernHeadlands:267:314:387:0", "Keelharbor:280:342:298:95", "CrowleyOrchard:210:166:261:427", "EmberstoneMine:281:351:639:43", "Greymanemanor:244:241:141:202", "KorothsDen:222:268:393:386", "TheBlackwald:280:224:504:394",},
				["SearingGorge"] = {"BlackcharCave:375:307:0:361", "BlackrockMountain:304:244:243:424", "DustfireValley:392:355:588:0", "FirewatchRidge:365:393:0:75", "GrimsiltWorksite:441:266:531:241", "TannerCamp:571:308:413:360", "TheCauldron:481:360:232:171", "ThoriumPoint:429:301:255:38",},
				["Silverpine"] = {"Ambermill:283:243:509:250", "BerensPeril:318:263:505:405", "DeepElemMine:217:198:483:212", "FenrisIsle:352:302:581:15", "ForsakenHighCommand:361:175:445:0", "ForsakenRearGuard:186:238:369:0", "NorthTidesBeachhead:174:199:323:68", "NorthTidesRun:281:345:147:0", "OlsensFarthing:251:167:312:249", "ShadowfangKeep:179:165:337:337", "TheBattlefront:255:180:349:429", "TheDecrepitFields:176:152:471:156", "TheForsakenFront:152:189:433:327", "TheGreymaneWall:409:162:318:506", "TheSepulcher:218:200:341:157", "TheSkitteringDark:227:172:236:0", "ValgansField:162:172:461:77",},
				["StranglethornJungle"] = {"BalAlRuins:159:137:267:168", "BaliaMahRuins:239:205:397:243", "Bambala:190:176:566:164", "FortLivingston:230:170:398:375", "GromGolBaseCamp:167:179:298:228", "KalAiRuins:139:150:354:184", "KurzensCompound:244:238:499:0", "LakeNazferiti:240:228:413:95", "Mazthoril:350:259:488:364", "MizjahRuins:157:173:387:246", "MoshOggOgreMound:234:206:543:253", "NesingwarysExpedition:227:190:306:63", "RebelCamp:302:166:306:0", "RuinsOfZulKunda:228:265:158:0", "TheVileReef:236:224:140:208", "ZulGurub:376:560:626:0", "ZuuldalaRuins:324:263:9:22",},
				["Sunwell"] = {"SunsReachHarbor:512:416:252:252", "SunsReachSanctum:512:512:251:4",},
				["SwampOfSorrows"] = {"Bogpaddle:262:193:600:0", "IthariusCave:268:316:7:242", "MarshtideWatch:330:342:478:0", "MistyreedStrand:402:668:600:0", "MistyValley:268:285:0:80", "PoolOfTears:257:229:575:238", "Sorrowmurk:229:418:703:80", "SplinterspearJunction:238:343:194:236", "Stagalbog:347:303:540:360", "Stonard:357:308:297:258", "TheHarborage:266:284:161:79", "TheShiftingMire:292:360:331:24",},
				["TheCapeOfStranglethorn"] = {"BootyBay:225:255:289:341", "CrystalveinMine:271:204:528:73", "GurubashiArena:238:260:345:0", "HardwrenchHideaway:356:221:208:116", "JagueroIsle:240:264:471:404", "MistvaleValley:253:242:408:248", "NekmaniWellspring:246:221:292:213", "RuinsofAboraz:184:176:533:181", "RuinsofJubuwal:155:221:468:119", "TheSundering:244:209:452:0", "WildShore:236:276:340:392",},
				["Tirisfal"] = {"AgamandMills:285:260:324:90", "BalnirFarmstead:242:179:594:324", "BrightwaterLake:210:292:573:122", "Brill:199:182:480:252", "CalstonEstate:179:169:389:255", "ColdHearthManor:212:177:418:317", "CrusaderOutpost:175:210:686:232", "Deathknell:431:407:9:207", "GarrensHaunt:190:214:477:129", "NightmareVale:225:281:347:325", "RuinsofLorderon:390:267:423:359", "ScarletMonastery:262:262:740:47", "ScarletWatchPost:161:234:692:99", "SollidenFarmstead:286:225:201:192", "TheBulwark:293:338:709:330", "VenomwebVale:250:279:752:150",},
				["TwilightHighlands"] = {"Bloodgulch:215:157:416:205", "CrucibleOfCarnage:203:208:387:268", "Crushblow:182:195:370:447", "DragonmawPass:283:206:76:120", "DragonmawPort:251:207:631:245", "DunwaldRuins:197:218:395:367", "FirebeardsPatrol:215:181:499:265", "GlopgutsHollow:174:190:291:89", "GorshakWarCamp:194:170:543:220", "GrimBatol:230:276:83:223", "Highbank:220:227:697:403", "HighlandForest:239:232:482:330", "HumboldtConflaguration:143:141:344:89", "Kirthaven:308:267:482:0", "ObsidianForest:342:288:436:380", "RuinsOfDrakgor:206:182:296:0", "SlitheringCove:198:201:622:169", "TheBlackBreach:211:210:498:121", "TheGullet:175:180:269:179", "TheKrazzworks:226:232:654:0", "TheTwilightBreach:199:212:312:192", "TheTwilightCitadel:361:354:151:314", "TheTwilightGate:165:199:327:356", "Thundermar:238:229:374:93", "TwilightShore:260:202:610:345", "VermillionRedoubt:324:264:71:16", "VictoryPoint:177:159:302:306", "WeepingWound:214:190:358:0", "WyrmsBend:191:198:205:232",},
				["TwilightHighlands_terrain1"] = {"Bloodgulch:215:157:416:205", "CrucibleOfCarnage:203:208:387:268", "Crushblow:182:195:370:447", "DragonmawPass:283:206:76:120", "DragonmawPort:251:207:631:245", "DunwaldRuins:197:218:395:367", "FirebeardsPatrol:215:181:499:265", "GlopgutsHollow:174:190:291:89", "GorshakWarCamp:194:170:543:220", "GrimBatol:230:276:83:223", "Highbank:220:227:697:403", "HighlandForest:239:232:482:330", "HumboldtConflaguration:143:141:344:89", "Kirthaven:308:267:482:0", "ObsidianForest:342:288:436:380", "RuinsOfDrakgor:206:182:296:0", "SlitheringCove:198:201:622:169", "TheBlackBreach:211:210:498:121", "TheGullet:175:180:269:179", "TheKrazzworks:226:232:654:0", "TheTwilightBreach:199:212:312:192", "TheTwilightCitadel:361:354:151:314", "TheTwilightGate:165:199:327:356", "Thundermar:238:229:374:93", "TwilightShore:260:202:610:345", "VermillionRedoubt:324:264:71:16", "VictoryPoint:177:159:302:306", "WeepingWound:214:190:358:0", "WyrmsBend:191:198:205:232",},
				["WesternPlaguelands"] = {"Andorhal:464:325:96:343", "CaerDarrow:194:208:601:390", "DalsonsFarm:325:192:300:232", "DarrowmereLake:492:314:510:354", "FelstoneField:241:212:229:228", "GahrronsWithering:241:252:495:213", "Hearthglen:432:271:235:0", "NorthridgeLumberCamp:359:182:231:123", "RedpineDell:290:133:286:211", "SorrowHill:368:220:261:448", "TheBulwark:316:316:48:235", "TheWeepingCave:185:230:551:151", "TheWrithingHaunt:169:195:472:332", "ThondrorilRiver:311:436:533:0",},
				["Westfall"] = {"AlexstonFarmstead:346:222:167:263", "DemontsPlace:201:195:203:376", "FurlbrowsPumpkinFarm:197:213:394:0", "GoldCoastQuarry:235:306:199:79", "JangoloadMine:196:229:311:0", "Moonbrook:232:213:308:325", "SaldeansFarm:244:237:451:81", "SentinelHill:229:265:404:226", "TheDaggerHills:292:273:303:395", "TheDeadAcre:193:273:531:200", "TheDustPlains:317:261:480:378", "TheGapingChasm:184:217:294:168", "TheJansenStead:202:179:474:0", "TheMolsenFarm:202:224:348:118", "WestfallLighthouse:211:167:221:477",},
				["Wetlands"] = {"AngerfangEncampment:236:256:359:201", "BlackChannelMarsh:301:232:37:240", "BluegillMarsh:321:248:31:102", "DireforgeHills:329:228:506:34", "DunAlgaz:298:215:346:419", "DunModr:257:185:356:7", "GreenwardensGrove:250:269:460:102", "IronbeardsTomb:185:224:372:76", "MenethilHarbor:325:363:0:297", "MosshideFen:369:235:506:232", "RaptorRidge:256:245:599:123", "Satlspray:250:282:218:0", "SlabchiselsSurvey:300:316:532:352", "SundownMarsh:276:243:121:63", "ThelganRock:258:207:371:335", "WhelgarsExcavationSite:298:447:185:195",},

				-- Kalimdor
				["AhnQirajTheFallenKingdom"] = {"AQKingdom:887:668:115:0",},
				["Ashenvale"] = {"Astranaar:251:271:255:164", "BoughShadow:166:211:836:148", "FallenSkyLake:287:276:529:385", "FelfireHill:277:333:714:317", "LakeFalathim:184:232:112:148", "MaelstrasPost:246:361:188:0", "NightRun:221:257:595:253", "OrendilsRetreat:244:251:143:0", "RaynewoodRetreat:231:256:481:221", "Satyrnaar:235:236:696:154", "SilverwindRefuge:347:308:338:335", "TheHowlingVale:325:239:473:97", "TheRuinsofStardust:236:271:210:331", "TheShrineofAssenia:306:283:40:275", "TheZoramStrand:262:390:0:0", "ThistlefurVillage:314:241:255:78", "ThunderPeak:203:310:377:121", "WarsongLumberCamp:231:223:771:265",},
				["Aszhara"] = {"BearsHead:256:224:113:141", "BilgewaterHarbor:587:381:395:127", "BitterReaches:321:247:477:0", "BlackmawHold:260:267:204:53", "DarnassianBaseCamp:243:262:343:3", "GallywixPleasurePalace:250:230:70:222", "LakeMennar:210:232:245:377", "OrgimmarRearGate:352:274:22:344", "RavencrestMonument:295:267:476:401", "RuinsofArkkoran:219:193:575:121", "RuinsofEldarath:218:237:228:229", "StormCliffs:207:232:407:403", "TheSecretLab:184:213:353:396", "TheShatteredStrand:206:329:316:168", "TowerofEldara:306:337:684:22",},
				["AzuremystIsle"] = {"AmmenFord:256:256:515:279", "AmmenVale:475:512:527:104", "AzureWatch:256:256:383:249", "BristlelimbVillage:256:256:174:363", "Emberglade:256:256:488:24", "FairbridgeStrand:256:128:356:0", "GreezlesCamp:256:256:507:350", "MoongrazeWoods:256:256:449:183", "OdesyusLanding:256:256:352:378", "PodCluster:256:256:281:305", "PodWreckage:128:256:462:349", "SiltingShore:256:256:291:3", "SilvermystIsle:256:222:23:446", "StillpineHold:256:256:365:49", "TheExodar:512:512:74:85", "ValaarsBerth:256:256:176:303", "WrathscalePoint:256:247:220:421",},
				["Barrens"] = {"BoulderLodeMine:278:209:511:7", "DreadmistPeak:241:195:290:104", "FarWatchPost:207:332:555:129", "GroldomFarm:243:217:448:127", "MorshanRampart:261:216:258:6", "Ratchet:219:175:547:379", "TheCrossroads:233:193:362:275", "TheDryHills:283:270:116:57", "TheForgottenPools:446:256:100:208", "TheMerchantCoast:315:212:556:456", "TheSludgeFen:257:249:403:6", "TheStagnantOasis:336:289:344:379", "TheWailingCaverns:377:325:152:318", "ThornHill:239:231:481:254",},
				["BloodmystIsle"] = {"AmberwebPass:256:512:44:62", "Axxarien:256:256:297:136", "BlacksiltShore:512:242:177:426", "Bladewood:256:256:367:209", "BloodscaleIsle:239:256:763:256", "BloodWatch:256:256:437:258", "BristlelimbEnclave:256:256:546:410", "KesselsCrossing:485:141:517:527", "Middenvale:256:256:414:406", "Mystwood:256:185:309:483", "Nazzivian:256:256:250:404", "RagefeatherRidge:256:256:481:117", "RuinsofLorethAran:256:256:556:216", "TalonStand:256:256:657:78", "TelathionsCamp:128:128:180:216", "TheBloodcursedReef:256:256:729:54", "TheBloodwash:256:256:302:27", "TheCrimsonReach:256:256:555:87", "TheCryoCore:256:256:293:285", "TheFoulPool:256:256:221:136", "TheHiddenReef:256:256:205:39", "TheLostFold:256:198:503:470", "TheVectorCoil:512:430:43:238", "TheWarpPiston:256:256:451:29", "VeridianPoint:256:256:637:0", "VindicatorsRest:256:256:232:242", "WrathscaleLair:256:256:598:338", "WyrmscarIsland:256:256:613:82",},
				["Desolace"] = {"CenarionWildlands:312:285:415:156", "GelkisVillage:274:196:207:472", "KodoGraveyard:250:215:360:273", "MagramTerritory:289:244:613:170", "MannorocCoven:326:311:381:357", "NijelsPoint:231:257:573:0", "RanzjarIsle:161:141:210:0", "Sargeron:317:293:655:0", "ShadowbreakRavine:292:266:637:402", "ShadowpreyVillage:222:299:142:369", "ShokThokar:309:349:589:319", "SlitherbladeShore:338:342:208:24", "TethrisAran:274:145:399:0", "ThargadsCamp:212:186:275:376", "ThunderAxeFortress:220:205:440:49", "ValleyofSpears:321:275:170:196",},
				["Durotar"] = {"DrygulchRavine:236:196:415:60", "EchoIsles:330:255:429:413", "NorthwatchFoothold:162:157:399:440", "Orgrimmar:259:165:309:0", "RazorHill:224:227:431:157", "RazormaneGrounds:248:158:302:264", "SenjinVillage:192:184:457:406", "SkullRock:208:157:438:0", "SouthfuryWatershed:244:222:282:174", "ThunderRidge:220:218:295:48", "TiragardeKeep:210:200:462:298", "ValleyOfTrials:254:258:304:312",},
				["Dustwallow"] = {"AlcazIsland:206:200:656:21", "BlackhoofVillage:344:183:199:0", "BrackenwllVillage:384:249:133:59", "DirehornPost:279:301:358:169", "Mudsprocket:433:351:109:313", "ShadyRestInn:317:230:137:188", "TheramoreIsle:305:247:542:223", "TheWyrmbog:436:299:359:369", "WitchHill:270:353:428:0",},
				["Dustwallow_terrain1"] = {"AlcazIsland:206:200:656:21", "BlackhoofVillage:344:183:199:0", "BrackenwllVillage:384:249:133:59", "DirehornPost:279:301:358:169", "Mudsprocket:433:351:109:313", "ShadyRestInn:317:230:137:188", "TheramoreIsle:305:247:542:223", "TheWyrmbog:436:299:359:369", "WitchHill:270:353:428:0",},
				["EversongWoods"] = {"AzurebreezeCoast:256:256:669:228", "DuskwitherGrounds:256:256:605:253", "EastSanctum:256:256:460:373", "ElrendarFalls:128:256:580:399", "FairbreezeVilliage:256:256:386:386", "FarstriderRetreat:256:128:524:359", "GoldenboughPass:256:128:243:469", "LakeElrendar:128:197:584:471", "NorthSanctum:256:256:361:298", "RuinsofSilvermoon:256:256:307:136", "RunestoneFalithas:256:172:378:496", "RunestoneShandor:256:174:464:494", "SatherilsHaven:256:256:324:384", "SilvermoonCity:512:512:440:87", "StillwhisperPond:256:256:474:314", "SunsailAnchorage:256:128:231:404", "SunstriderIsle:512:512:195:5", "TheGoldenStrand:128:253:183:415", "TheLivingWood:128:248:511:420", "TheScortchedGrove:256:128:255:507", "ThuronsLivery:256:128:539:305", "TorWatha:256:353:648:315", "TranquilShore:256:256:215:298", "WestSanctum:128:256:292:319", "Zebwatha:128:193:554:475",},
				["Felwood"] = {"BloodvenomFalls:345:192:220:231", "DeadwoodVillage:173:163:410:505", "EmeraldSanctuary:274:212:394:382", "FelpawVillage:307:161:471:0", "IrontreeWoods:261:273:406:55", "JadefireGlen:229:210:288:458", "JadefireRun:263:199:303:9", "Jaedenar:319:176:234:317", "MorlosAran:187:176:476:484", "RuinsofConstellas:268:214:278:359", "ShatterScarVale:343:250:243:107", "TalonbranchGlade:209:226:531:57",},
				["Feralas"] = {"CampMojache:174:220:671:181", "DarkmistRuins:172:198:568:287", "DireMaul:265:284:485:101", "FeathermoonStronghold:217:192:362:237", "FeralScar:191:179:457:281", "GordunniOutpost:192:157:663:116", "GrimtotemCompund:159:218:607:170", "LowerWilds:207:209:756:191", "RuinsofFeathermoon:208:204:186:229", "RuinsofIsildien:206:237:467:354", "TheForgottenCoast:194:304:375:343", "TheTwinColossals:350:334:271:0", "WrithingDeep:232:206:652:298",},
				["Hyjal_terrain1"] = {"ArchimondesVengeance:270:300:320:5", "AshenLake:282:418:6:78", "DarkwhisperGorge:320:471:682:128", "DireforgeHill:270:173:303:197", "GatesOfSothann:272:334:622:320", "Nordrassil:537:323:392:0", "SethriasRoost:277:232:139:436", "ShrineOfGoldrinn:291:321:116:17", "TheRegrowth:441:319:52:253", "TheScorchedPlain:365:264:411:216", "TheThroneOfFlame:419:290:318:378",},
				["Hyjal"] = {"ArchimondesVengeance:270:300:320:5", "AshenLake:282:418:6:78", "DarkwhisperGorge:320:471:682:128", "DireforgeHill:270:173:303:197", "GatesOfSothann:272:334:622:320", "Nordrassil:537:323:392:0", "SethriasRoost:277:232:139:436", "ShrineOfGoldrinn:291:321:116:17", "TheRegrowth:441:319:52:253", "TheScorchedPlain:365:264:411:216", "TheThroneOfFlame:419:290:318:378",},
				["Moonglade"] = {"LakeEluneara:431:319:219:273", "Nighthaven:346:244:370:135", "ShrineofRemulos:271:296:209:91", "StormrageBarrowDens:275:346:542:210",},
				["Mulgore"] = {"BaeldunDigsite:218:192:226:220", "BloodhoofVillage:302:223:319:273", "PalemaneRock:172:205:248:321", "RavagedCaravan:187:165:435:224", "RedCloudMesa:446:264:286:401", "RedRocks:186:185:514:43", "StonetalonPass:237:184:201:0", "TheGoldenPlains:186:216:448:101", "TheRollingPlains:260:243:527:291", "TheVentureCoMine:208:300:530:138", "ThunderBluff:373:259:208:62", "ThunderhornWaterWell:201:167:333:202", "WildmaneWaterWell:190:172:331:0", "WindfuryRidge:222:202:400:0", "WinterhoofWaterWell:174:185:449:340",},
				["Silithus"] = {"CenarionHold:292:260:427:143", "HiveAshi:405:267:345:4", "HiveRegal:489:358:380:310", "HiveZora:542:367:0:206", "SouthwindVillage:309:243:550:181", "TheCrystalVale:329:246:126:0", "TheScarabWall:580:213:0:455", "TwilightBaseCamp:434:231:100:151", "ValorsRest:315:285:614:0",},
				["SouthernBarrens"] = {"BaelModan:269:211:398:457", "Battlescar:384:248:274:307", "ForwardCommand:216:172:423:251", "FrazzlecrazMotherload:242:195:269:436", "HonorsStand:315:170:201:0", "HuntersHill:218:178:300:64", "NorthwatchHold:280:279:548:147", "RazorfenKraul:214:140:273:528", "RuinsofTaurajo:285:171:244:286", "TheOvergrowth:355:226:289:117", "VendettaPoint:254:214:267:196",},
				["StonetalonMountains"] = {"BattlescarValley:290:297:220:189", "BoulderslideRavine:194:156:532:512", "CliffwalkerPost:241:192:366:95", "GreatwoodVale:322:220:602:448", "KromgarFortress:183:196:588:341", "Malakajin:211:131:618:537", "MirkfallonLake:244:247:417:143", "RuinsofEldrethar:221:235:367:411", "StonetalonPeak:305:244:265:0", "SunRockRetreat:222:222:353:285", "ThaldarahOverlook:210:189:252:121", "TheCharredVale:277:274:199:368", "UnearthedGrounds:265:206:654:369", "WebwinderHollow:164:258:479:401", "WebwinderPath:267:352:468:263", "WindshearCrag:374:287:533:179", "WindshearHold:176:189:516:289",},
				["Tanaris"] = {"AbyssalSands:255:194:297:148", "BrokenPillar:195:163:413:211", "CavernsofTime:213:173:507:238", "DunemaulCompound:231:177:305:257", "EastmoonRuins:173:163:380:341", "Gadgetzan:189:180:412:92", "GadgetzanBay:254:341:479:9", "LandsEndBeach:224:216:431:452", "LostRiggerCover:178:243:615:201", "SandsorrowWatch:214:149:293:99", "SouthbreakShore:274:186:437:289", "SouthmoonRuins:232:211:301:349", "TheGapingChasm:225:187:448:364", "TheNoxiousLair:179:190:258:211", "ThistleshrubValley:221:293:185:280", "ValleryoftheWatchers:269:190:255:431", "ZulFarrak:315:190:184:0",},
				["Teldrassil"] = {"BanethilHollow:175:235:374:221", "Darnassus:298:337:149:181", "GalardellValley:178:186:466:237", "GnarlpineHold:198:181:347:355", "LakeAlameth:289:202:422:310", "PoolsofArlithrien:140:210:345:243", "RutheranVillage:317:220:329:448", "Shadowglen:241:217:481:104", "StarbreezeVillage:187:196:544:217", "TheCleft:144:226:432:109", "TheOracleGlade:194:244:276:90", "WellspringLake:165:249:382:83",},
				["ThousandNeedles"] = {"DarkcloudPinnacle:317:252:169:116", "FreewindPost:436:271:276:186", "Highperch:246:380:0:134", "RazorfenDowns:361:314:298:0", "RustmaulDiveSite:234:203:527:465", "SouthseaHoldfast:246:256:756:412", "SplithoofHeights:431:410:571:49", "TheGreatLift:272:232:136:0", "TheShimmeringDeep:411:411:591:257", "TheTwilightWithering:374:339:347:329", "TwilightBulwark:358:418:125:241", "WestreachSummit:280:325:0:0",},
				["Uldum"] = {"AkhenetFields:164:185:471:277", "CradelOfTheAncient:202:169:341:402", "HallsOfOrigination:269:242:599:184", "KhartutsTomb:203:215:542:0", "LostCityOfTheTolVir:233:321:527:291", "Marat:160:193:406:174", "Nahom:237:194:583:162", "Neferset:209:254:407:384", "ObeliskOfTheMoon:400:224:110:0", "ObeliskOfTheStars:196:170:551:121", "ObeliskOfTheSun:269:203:340:282", "Orsis:249:243:264:136", "Ramkahen:228:227:411:67", "RuinsOfAhmtul:278:173:365:0", "RuinsOfAmmon:203:249:217:289", "Schnottzslanding:312:289:28:221", "TahretGrounds:150:159:545:193", "TempleofUldum:296:209:132:127", "TheCursedlanding:237:316:752:170", "TheGateofUnendingCycles:161:236:647:15", "TheTrailOfDevestation:206:204:657:349", "TheVortexPinnacle:213:195:656:473", "ThroneOfTheFourWinds:270:229:229:433", "VirnaalDam:151:144:479:215",},
				["Uldum_terrain1"] = {"AkhenetFields:164:185:471:277", "CradelOfTheAncient:202:169:341:402", "HallsOfOrigination:269:242:599:184", "KhartutsTomb:203:215:542:0", "LostCityOfTheTolVir:233:321:527:291", "Marat:160:193:406:174", "Nahom:237:194:583:162", "Neferset:209:254:407:384", "ObeliskOfTheMoon:400:224:110:0", "ObeliskOfTheStars:196:170:551:121", "ObeliskOfTheSun:269:203:340:282", "Orsis:249:243:264:136", "Ramkahen:228:227:411:67", "RuinsOfAhmtul:278:173:365:0", "RuinsOfAmmon:203:249:217:289", "Schnottzslanding:312:289:28:221", "TahretGrounds:150:159:545:193", "TempleofUldum:296:209:132:127", "TheCursedlanding:237:316:752:170", "TheGateofUnendingCycles:161:236:647:15", "TheTrailOfDevestation:206:204:657:349", "TheVortexPinnacle:213:195:656:473", "ThroneOfTheFourWinds:270:229:229:433", "VirnaalDam:151:144:479:215",},
				["UngoroCrater"] = {"FirePlumeRidge:321:288:356:192", "FungalRock:224:191:557:0", "GolakkaHotSprings:309:277:145:226", "IronstonePlateau:197:222:706:201", "LakkariTarPits:432:294:305:0", "MarshalsStand:204:170:462:330", "MossyPile:186:185:328:179", "TerrorRun:316:293:162:357", "TheMarshlands:263:412:573:256", "TheRollingGarden:337:321:565:39", "TheScreamingReaches:332:332:157:0", "TheSlitheringScar:381:274:335:384",},
				["Winterspring"] = {"Everlook:194:229:482:195", "FrostfireHotSprings:376:289:93:118", "FrostsaberRock:332:268:304:0", "FrostwhisperGorge:317:183:424:474", "IceThistleHills:249:217:581:314", "LakeKeltheril:271:258:372:268", "Mazthoril:257:238:399:340", "OwlWingThicket:254:150:556:439", "StarfallVillage:367:340:229:33", "TheHiddenGrove:333:255:500:17", "TimbermawPost:362:252:92:302", "WinterfallVillage:221:209:588:181",},

				-- Outland
				["BladesEdgeMountains"] = {"BashirLanding:256:256:422:0", "BladedGulch:256:256:623:147", "BladesipreHold:256:507:314:161", "BloodmaulCamp:256:256:412:95", "BloodmaulOutpost:256:297:342:371", "BrokenWilds:256:256:733:109", "CircleofWrath:256:256:439:210", "DeathsDoor:256:419:512:249", "ForgeCampAnger:416:256:586:147", "ForgeCampTerror:512:252:144:416", "ForgeCampWrath:256:256:254:176", "Grishnath:256:256:286:28", "GruulsLayer:256:256:527:81", "JaggedRidge:256:254:446:414", "MokNathalVillage:256:256:658:297", "RavensWood:512:256:214:55", "RazorRidge:256:336:533:332", "RidgeofMadness:256:410:554:258", "RuuanWeald:256:512:479:98", "Skald:256:256:673:71", "Sylvanaar:256:318:289:350", "TheCrystalpine:256:256:585:0", "ThunderlordStronghold:256:396:405:272", "VeilLashh:256:240:271:428", "VeilRuuan:256:128:563:151", "VekhaarStand:256:256:629:406", "VortexPinnacle:256:462:166:206",},
				["Hellfire"] = {"DenofHaalesh:256:256:182:412", "ExpeditionArmory:512:255:261:413", "FalconWatch:512:342:183:326", "FallenSkyRidge:256:256:34:142", "ForgeCampRage:512:512:478:25", "HellfireCitadel:256:458:338:210", "HonorHold:256:256:469:298", "MagharPost:256:256:206:110", "PoolsofAggonar:256:512:326:45", "RuinsofShanaar:256:378:25:290", "TempleofTelhamat:512:512:38:152", "TheLegionFront:256:512:579:128", "TheStairofDestiny:256:512:737:156", "Thrallmar:256:256:467:154", "ThroneofKiljaeden:512:256:477:6", "VoidRidge:256:256:705:368", "WarpFields:256:260:308:408", "ZethGor:422:238:580:430",},
				["Nagrand"] = {"BurningBladeRUins:256:334:660:334", "ClanWatch:256:256:532:363", "ForgeCampFear:512:420:36:248", "ForgeCampHate:256:256:162:154", "Garadar:256:256:431:143", "Halaa:256:256:335:193", "KilsorrowFortress:256:241:558:427", "LaughingSkullRuins:256:256:351:52", "OshuGun:512:334:168:334", "RingofTrials:256:256:533:267", "SouthwindCleft:256:256:391:258", "SunspringPost:256:256:219:199", "Telaar:256:256:387:390", "ThroneoftheElements:256:256:504:53", "TwilightRidge:256:512:10:107", "WarmaulHill:256:256:157:32", "WindyreedPass:256:256:598:79", "WindyreedVillage:256:256:666:233", "ZangarRidge:256:256:277:54",},
				["Netherstorm"] = {"Area52:256:128:241:388", "ArklonRuins:256:256:328:397", "CelestialRidge:256:256:644:173", "EcoDomeFarfield:256:256:396:10", "EtheriumStagingGrounds:256:256:481:208", "ForgeBaseOG:256:256:237:22", "KirinVarVillage:256:145:490:523", "ManaforgeBanar:256:387:147:281", "ManaforgeCoruu:256:179:357:489", "ManaforgeDuro:256:256:465:336", "ManafrogeAra:256:256:171:155", "Netherstone:256:256:411:20", "NetherstormBridge:256:256:132:294", "RuinedManaforge:256:256:513:138", "RuinsofEnkaat:256:256:253:301", "RuinsofFarahlon:512:256:354:49", "SocretharsSeat:256:256:229:38", "SunfuryHold:256:217:454:451", "TempestKeep:409:384:593:284", "TheHeap:256:213:239:455", "TheScrapField:256:256:356:261", "TheStormspire:256:256:298:134",},
				["ShadowmoonValley"] = {"AltarofShatar:256:256:520:93", "CoilskarPoint:512:512:348:8", "EclipsePoint:512:358:343:310", "IlladarPoint:256:256:143:256", "LegionHold:512:512:104:155", "NetherwingCliffs:256:256:554:308", "NetherwingLedge:492:223:510:445", "ShadowmoonVilliage:512:512:116:35", "TheBlackTemple:396:512:606:126", "TheDeathForge:256:512:290:129", "TheHandofGuldan:512:512:394:90", "TheWardensCage:512:410:469:258", "WildhammerStronghold:512:439:168:229",}, 
				["TerokkarForest"] = {"AllerianStronghold:256:256:480:277", "AuchenaiGrounds:256:234:247:434", "BleedingHollowClanRuins:256:367:103:301", "BonechewerRuins:256:256:521:275", "CarrionHill:256:256:377:272", "CenarionThicket:256:256:314:0", "FirewingPoint:385:512:617:149", "GrangolvarVilliage:512:256:143:171", "RaastokGlade:256:256:505:154", "RazorthornShelf:256:256:478:19", "RefugeCaravan:128:256:316:268", "RingofObservance:256:256:310:345", "SethekkTomb:256:256:245:289", "ShattrathCity:512:512:104:4", "SkethylMountains:512:320:449:348", "SmolderingCaravan:256:208:321:460", "StonebreakerHold:256:256:397:165", "TheBarrierHills:256:256:116:4", "Tuurem:256:512:455:34", "VeilRhaze:256:256:222:362", "WrithingMound:256:256:417:327",},
				["Zangarmarsh"] = {"AngoroshGrounds:256:256:88:50", "AngoroshStronghold:256:128:124:0", "BloodscaleEnclave:256:256:596:412", "CenarionRefuge:308:256:694:321", "CoilfangReservoir:256:512:462:90", "FeralfenVillage:512:336:314:332", "MarshlightLake:256:256:81:152", "OreborHarborage:256:512:329:25", "QuaggRidge:256:343:141:325", "Sporeggar:512:256:20:202", "Telredor:256:512:569:112", "TheDeadMire:286:512:716:128", "TheHewnBog:256:512:219:51", "TheLagoon:256:256:512:303", "TheSpawningGlen:256:256:31:339", "TwinspireRuins:256:256:342:249", "UmbrafenVillage:256:207:720:461", "ZabraJin:256:256:175:232",},

				-- Northrend
				["BoreanTundra"] = {"AmberLedge:244:214:325:140", "BorGorokOutpost:396:203:314:0", "Coldarra:460:381:50:0", "DeathsStand:289:279:707:181", "GarroshsLanding:267:378:153:238", "Kaskala:385:316:509:214", "RiplashStrand:382:258:293:383", "SteeljawsCaravan:244:319:397:66", "TempleCityOfEnKilah:290:292:712:15", "TheDensOfDying:203:209:662:11", "TheGeyserFields:375:342:480:0", "TorpsFarm:186:276:272:237", "ValianceKeep:259:302:457:264", "WarsongStronghold:260:278:329:237",},
				["CrystalsongForest"] = {"ForlornWoods:544:668:129:0", "SunreaversCommand:446:369:536:40", "TheAzureFront:416:424:0:244", "TheDecrepitFlow:288:222:0:0", "TheGreatTree:252:260:0:91", "TheUnboundThicket:502:477:500:105", "VioletStand:264:303:0:176", "WindrunnersOverlook:558:285:444:383",},
				["Dragonblight"] = {"AgmarsHammer:236:218:258:203", "Angrathar:306:242:210:0", "ColdwindHeights:213:219:403:0", "EmeraldDragonshrine:196:218:543:362", "GalakrondsRest:258:225:433:118", "IcemistVillage:235:337:134:165", "LakeIndule:356:300:217:313", "LightsRest:299:278:703:7", "Naxxramas:311:272:691:160", "NewHearthglen:214:261:614:358", "ObsidianDragonshrine:304:203:256:104", "RubyDragonshrine:188:211:374:208", "ScarletPoint:235:354:569:7", "TheCrystalVice:229:259:487:0", "TheForgottenShore:301:286:698:332", "VenomSpite:226:212:661:264", "WestwindRefugeeCamp:229:299:42:187", "WyrmrestTemple:317:353:453:219",},
				["GrizzlyHills"] = {"AmberpineLodge:278:290:217:244", "BlueSkyLoggingGrounds:249:235:232:129", "CampOneqwah:324:265:548:137", "ConquestHold:332:294:17:307", "DrakilJinRuins:351:284:607:41", "DrakTheronKeep:382:285:0:46", "DunArgol:455:400:547:257", "GraniteSprings:356:224:7:207", "GrizzleMaw:294:227:358:187", "RageFangShrine:475:362:312:294", "ThorModan:329:246:509:0", "UrsocsDen:328:260:331:32", "VentureBay:274:207:18:461", "Voldrune:283:247:176:421",},
				["HowlingFjord"] = {"AncientLift:177:191:342:351", "ApothecaryCamp:263:265:99:37", "BaelgunsExcavationSite:244:305:621:327", "Baleheim:174:173:576:170", "CampWinterHoof:223:209:354:0", "CauldrosIsle:181:178:490:161", "EmberClutch:213:256:283:203", "ExplorersLeagueOutpost:232:216:585:336", "FortWildervar:251:192:490:0", "GiantsRun:298:306:572:0", "Gjalerbron:242:189:225:0", "Halgrind:187:263:397:208", "IvaldsRuin:193:201:668:223", "Kamagua:333:265:99:278", "NewAgamand:284:308:415:360", "Nifflevar:178:208:595:240", "ScalawagPoint:350:258:168:410", "Skorn:238:232:343:108", "SteelGate:222:168:222:100", "TheTwistedGlade:266:210:420:57", "UtgardeKeep:248:382:477:216", "VengeanceLanding:223:338:664:25", "WestguardKeep:347:220:90:180",},
				["IcecrownGlacier"] = {"Aldurthar:373:375:355:37", "ArgentTournamentGround:314:224:616:30", "Corprethar:308:212:342:392", "IcecrownCitadel:308:202:392:466", "Jotunheim:393:474:22:122", "OnslaughtHarbor:204:268:0:167", "Scourgeholme:245:239:690:267", "SindragosasFall:300:343:626:31", "TheBombardment:248:243:538:181", "TheBrokenFront:283:231:558:329", "TheConflagration:227:210:327:305", "TheFleshwerks:219:283:218:291", "TheShadowVault:223:399:321:15", "Valhalas:238:240:217:50", "ValleyofEchoes:269:217:715:390", "Ymirheim:223:207:444:276",},
				["SholazarBasin"] = {"KartaksHold:329:293:76:375", "RainspeakerCanopy:207:235:427:244", "RiversHeart:468:329:359:339", "TheAvalanche:322:265:596:92", "TheGlimmeringPillar:294:327:308:34", "TheLifebloodPillar:312:369:501:134", "TheMakersOverlook:233:286:705:236", "TheMakersPerch:249:248:172:135", "TheMosslightPillar:239:313:265:355", "TheSavageThicket:293:229:396:51", "TheStormwrightsShelf:268:288:138:58", "TheSuntouchedPillar:455:316:82:186",},
				["TheStormPeaks"] = {"BorsBreath:322:195:109:375", "BrunnhildarVillage:305:298:339:370", "DunNiffelem:309:383:481:285", "EngineoftheMakers:210:179:316:296", "Frosthold:244:220:134:429", "GarmsBane:184:191:395:470", "NarvirsCradle:180:239:214:144", "Nidavelir:221:200:108:206", "SnowdriftPlains:205:232:162:143", "SparksocketMinefield:251:200:242:468", "TempleofLife:182:270:570:113", "TempleofStorms:169:164:239:301", "TerraceoftheMakers:363:341:292:122", "Thunderfall:306:484:627:179", "Ulduar:369:265:218:0", "Valkyrion:228:158:98:318",},
				["ZulDrak"] = {"AltarOfHarKoa:265:257:533:345", "AltarOfMamToth:311:317:575:88", "AltarOfQuetzLun:261:288:607:251", "AltarOfRhunok:247:304:431:127", "AltarOfSseratus:237:248:288:168", "AmphitheaterOfAnguish:266:254:289:287", "DrakSotraFields:286:265:326:358", "GunDrak:336:297:629:0", "Kolramas:302:231:380:437", "LightsBreach:321:305:181:363", "ThrymsEnd:272:268:0:247", "Voltarus:218:291:174:191", "Zeramas:307:256:7:412", "ZimTorga:249:258:479:241",},

				-- Cataclysm
				["Deepholm"] = {"CrimsonExpanse:462:400:540:12", "DeathwingsFall:454:343:549:297", "NeedlerockChasm:378:359:20:0", "NeedlerockSlag:370:285:0:146", "ScouredReach:516:287:448:0", "StoneHearth:371:354:0:314", "StormsFuryWreckage:292:285:458:383", "TempleOfEarth:355:345:287:177", "ThePaleRoost:467:273:85:0", "TherazanesThrone:274:156:434:0", "TheShatteredField:430:230:141:438", "TwilightOverlook:411:248:570:420", "TwilightTerrace:237:198:297:384",},
				["Kezan"] = {"BilgewaterPort:694:290:163:148", "Drudgetown:351:301:180:367", "FirstbankofKezan:376:343:98:325", "GallywixsVilla:303:452:0:41", "Kajamine:354:360:586:308", "KajaroField:250:307:383:260", "KezanMap:1002:664:0:4", "SwindleStreet:168:213:317:232",},
				["TheLostIsles"] = {"Alliancebeachhead:177:172:129:348", "BilgewaterLumberyard:248:209:462:43", "GallywixDocks:173:180:351:21", "HordeBaseCamp:222:190:244:458", "KTCOilPlatform:156:142:433:11", "landingSite:142:133:377:359", "Lostpeak:350:517:581:21", "OoomlotVillage:221:211:508:345", "Oostan:210:258:492:161", "RaptorRise:168:205:416:368", "RuinsOfVashelan:212:216:440:452", "ScorchedGully:305:288:323:185", "ShipwreckShore:172:175:189:408", "SkyFalls:190:186:416:131", "TheSavageGlen:231:216:213:325", "TheSlavePits:212:193:279:68", "WarchiefsLookout:159:230:264:144",},
				["TheLostIsles_terrain1"] = {"Alliancebeachhead:177:172:129:348", "BilgewaterLumberyard:248:209:462:43", "GallywixDocks:173:180:351:21", "HordeBaseCamp:222:190:244:458", "KTCOilPlatform:156:142:433:11", "landingSite:142:133:377:359", "Lostpeak:350:517:581:21", "OoomlotVillage:221:211:508:345", "Oostan:210:258:492:161", "RaptorRise:168:205:416:368", "RuinsOfVashelan:212:216:440:452", "ScorchedGully:305:288:323:185", "ShipwreckShore:172:175:189:408", "SkyFalls:190:186:416:131", "TheSavageGlen:231:216:213:325", "TheSlavePits:212:193:279:68", "WarchiefsLookout:159:230:264:144",},
				["TheLostIsles_terrain2"] = {"Alliancebeachhead:177:172:129:348", "BilgewaterLumberyard:248:209:462:43", "GallywixDocks:173:180:351:21", "HordeBaseCamp:222:190:244:458", "KTCOilPlatform:156:142:433:11", "landingSite:142:133:377:359", "Lostpeak:350:517:581:21", "OoomlotVillage:221:211:508:345", "Oostan:210:258:492:161", "RaptorRise:168:205:416:368", "RuinsOfVashelan:212:216:440:452", "ScorchedGully:305:288:323:185", "ShipwreckShore:172:175:189:408", "SkyFalls:190:186:416:131", "TheSavageGlen:231:216:213:325", "TheSlavePits:212:193:279:68", "WarchiefsLookout:159:230:264:144",},
				["VashjirDepths"] = {"AbandonedReef:371:394:50:263", "AbyssalBreach:491:470:497:0", "ColdlightChasm:267:374:266:280", "DeepfinRidge:363:262:275:32", "FireplumeTrench:298:251:315:110", "KorthunsEnd:370:385:412:283", "LGhorek:306:293:162:210", "Seabrush:225:250:415:183",},
				["VashjirKelpForest"] = {"DarkwhisperGorge:220:189:528:228", "GnawsBoneyard:311:217:451:325", "GubogglesLedge:227:207:399:280", "HoldingPens:316:267:456:401", "HonorsTomb:291:206:380:43", "LegionsFate:278:315:210:35", "TheAccursedReef:340:225:365:162",},
				["VashjirRuins"] = {"BethMoraRidge:335:223:407:445", "GlimmeringdeepGorge:272:180:270:222", "Nespirah:286:269:460:261", "RuinsOfTherseral:197:223:554:175", "RuinsOfVashjir:349:361:217:268", "ShimmeringGrotto:339:278:400:0", "SilverTideHollow:480:319:150:32",},

				-- Pandaria
				["DreadWastes"] = {"KLAXXIVESS:236:206:458:110", "ZANVESS:290:283:162:385", "BREWGARDEN:250:218:351:0", "DREADWATERLAKE:322:211:437:313", "CLUTCHESOFSHEKZEER:209:318:341:125", "HORRIDMARCH:323:194:441:224", "BRINYMUCK:325:270:214:311", "SOGGYSGAMBLE:268:241:450:406", "TERRACEOFGURTHAN:209:234:593:92", "RIKKITUNVILLAGE:218:186:236:32", "HEARTOFFEAR:262:293:191:122", "KYPARIVOR:325:190:485:0",},
				["Krasarang"] = {"RedwingRefuge:212:265:317:63", "AnglersOutpost:265:194:545:205", "TempleOfTheRedCrane:219:259:300:215", "DojaniRiver:190:282:513:3", "krasarangCove:286:268:701:19", "TheDeepwild:188:412:397:59", "LostDynasty:217:279:589:27", "FallsongRiver:214:393:218:77", "TheSouthernIsles:252:313:23:267", "ZhusBastion:306:204:612:0", "RuinsOfDojan:204:383:444:44", "TheForbiddenJungle:257:300:0:79", "RuinsOfKorja:211:395:125:88", "CradleOfChiJi:272:250:176:376", "UngaIngoo:258:170:330:498", "NayeliLagoon:246:240:343:373",},
				["Krasarang_terrain1"] = {"Zhusbastion:306:204:612:0", "FallsongRiver:214:393:218:77", "DojaniRiver:190:282:513:3", "RuinsOfDojan:204:383:444:44", "TheDeepWild:188:412:397:59", "Nayelilagoon:246:240:343:373", "Ungaingoo:258:170:330:498", "KrasarangCove:295:293:701:19", "RuinsOfKorja:211:395:125:88", "LostDynasty:217:279:589:27", "TheSouthernIsles:275:329:0:267", "AnglerSoutpost:347:199:545:200", "TheForbiddenJungle:257:300:0:79", "RedWingRefuge:212:265:317:63", "TempleOfTheRedCrane:219:259:300:215", "CradleOfChiji:272:250:176:376",},
				["KunLaiSummit"] = {"BinanVillage:240:198:607:470", "Mogujia:253:208:462:411", "MuskpawRanch:229:262:603:313", "MountNeverset:313:208:228:264", "ZouchinVillage:298:219:502:64", "TempleoftheWhitetiger:250:260:587:170", "GateoftheAugust:261:162:449:506", "ShadoPanMonastery:385:385:88:92", "TheBurlapTrail:310:276:398:310", "PeakOfSerenity:287:277:333:63", "ValleyOfEmperors:224:241:453:191", "Kotapeak:252:257:233:360", "Iseoflostsouls:259:233:602:4", "FireboughNook:224:172:322:496", "TEMPLEOFTHEWHITETIGER:250:260:587:170",},
				["TheHiddenPass"] = {"TheHiddenCliffs:294:220:433:0", "TheBlackMarket:479:493:371:175", "TheHiddenSteps:290:191:412:477",},
				["TheJadeForest"] = {"GlassfinVillage:278:310:525:358", "RuinsOfGanShi:196:158:316:0", "TheArboretum:242:210:481:215", "WindlessIsle:251:348:539:43", "DawnsBlossom:234:210:325:178", "TempleOfTheJadeSerpent:264:211:468:295", "DreamersPavillion:218:148:474:520", "NectarbreezeOrchard:219:256:290:330", "HellscreamsHope:196:166:181:75", "SlingtailPits:179:180:428:416", "SerpentsSpine:191:216:388:299", "ChunTianMonastery:227:198:300:56", "JadeMines:236:142:400:146", "EmperorsOmen:202:204:430:21", "GrookinMound:253:229:182:214", "WreckOfTheSkyShark:210:158:202:0", "Waywardlanding:219:186:346:482", "NookaNooka:219:205:189:151",},
				["TheWanderingIsle"] = {"TheDawningValley:677:668:325:0", "TempleofFiveDawns:607:461:395:182", "MandoriVillage:610:374:392:294", "RidgeofLaughingWinds:313:321:183:198", "Pei-WuForest:651:262:351:406", "PoolofthePaw:220:188:297:324", "SkyfireCrash-Site:346:263:124:405", "TheRows:385:373:504:295", "TheSingingPools:372:475:545:12", "MorningBreezeVillage:261:315:203:36", "Fe-FangVillage:234:286:134:9", "TheWoodofStaves:989:466:13:202",},
				["TownlongWastes"] = {"NiuzaoTemple:296:359:213:241", "ShanzeDao:300:246:125:0", "TheSumprushes:271:205:545:369", "Sikvess:261:235:306:433", "GaoRanBlockade:353:200:546:468", "MingChiCrossroads:247:221:417:447", "palewindVillage:282:306:692:362", "OsulMesa:238:296:560:185", "ShadoPanGarrison:213:170:413:385", "KriVess:255:269:420:209", "SriVess:294:283:92:192",},
				["ValeofEternalBlossoms"] = {"GuoLaiRuins:337:349:87:3", "WhiteMoonShrine:298:262:482:10", "MistfallVillage:310:305:200:363", "SettingSunTraining:350:429:0:234", "TuShenBurialGround:267:308:349:316", "TheStairsAscent:446:359:556:267", "WinterboughGlade:361:333:4:107", "TheGoldenStair:242:254:328:16", "WhitepetalLake:267:281:278:170", "TheTwinMonoliths:272:522:444:97", "MoguShanPalace:373:385:629:22",},
				["ValleyoftheFourWinds"] = {"ThunderfootFields:380:317:622:0", "PoolsofPurity:213:246:513:58", "RumblingTerrace:277:245:582:301", "PaoquanHollow:273:246:12:105", "StormsoutBrewery:257:288:227:380", "DustbackGorge:209:308:0:343", "CliffsofDispair:510:264:215:404", "Theheartland:286:392:253:75", "SilkenFields:254:259:530:253", "HarvestHome:260:251:5:239", "GildedFan:208:292:438:41", "GrandGranery:314:212:334:325", "SingingMarshes:175:291:170:130", "ZhusDecent:303:323:699:114", "Halfhill:206:245:438:177", "NesingwarySafari:249:342:104:326", "MudmugsPlace:230:217:561:161", "KuzenVillage:199:304:224:74",},

			}

			-- Initialise counters
			local createdtex = 0
			local texcount = 0

			-- Create local texture table
			local MapTex = {}

			-- Map refresh function
			local function RefMap()

				if texcount > 0 then
					for i = 1, texcount do
						MapTex[i]:Hide()
					end
					texcount = 0; 
				end

				-- Get current map
				local filename, texheight, void, void, sub = GetMapInfo()
				if sub then return end
				if not filename then return end

				local texpath = format([[Interface\WorldMap\%s\]], filename)
				local zone = LeaPlusMapData[filename] or {}

				-- Create new textures for current map
				for travnum, num in next, zone do
					local tname, texwidth, texheight, offsetx, offsety = strsplit(":", num)
					local texturename = texpath .. tname
					--if filename == "Gilneas" then aa,bb,cc,dd,ee,ff,gg = GetMapOverlayInfo(travnum); print(aa,bb,cc,dd,ee,ff,gg); end
					local numtexwide, numtextall = math.ceil(texwidth / 256), math.ceil(texheight / 256)

					-- Work out how many textures are needed to fill the map
					local neededtex = texcount + numtextall * numtexwide

					-- Create the textures
					if neededtex > createdtex then
						for j = createdtex + 1, neededtex do
							MapTex[j] = WorldMapDetailFrame:CreateTexture(nil, "ARTWORK")
						end
						createdtex = neededtex
					end

					-- Process textures
					for j = 1, numtextall do
						local texturepxheight, texturefileheight
						if j < numtextall then
							texturepxheight = 256
							texturefileheight = 256
						else
							texturepxheight = texheight % 256
							if texturepxheight == 0 then
								texturepxheight = 256
							end
							texturefileheight = 16
							while texturefileheight < texturepxheight do
								texturefileheight = texturefileheight * 2
							end
						end

						for k = 1, numtexwide do
							if texcount > createdtex then return end
							texcount = texcount + 1
							local texture = MapTex[texcount]
							local texturepxwidth
							local texturefilewidth
							if k < numtexwide then
								texturepxwidth = 256
								texturefilewidth = 256
							else
								texturepxwidth = texwidth % 256
								if texturepxwidth == 0 then
									texturepxwidth = 256
								end
								texturefilewidth = 16
								while texturefilewidth < texturepxwidth do
									texturefilewidth = texturefilewidth * 2
								end
							end 
							texture:SetWidth(texturepxwidth)
							texture:SetHeight(texturepxheight)
							texture:SetTexCoord(0, texturepxwidth/texturefilewidth, 0, texturepxheight/texturefileheight)
							texture:ClearAllPoints()						  
							texture:SetPoint("TOPLEFT", "WorldMapDetailFrame", "TOPLEFT", offsetx + (256 * (k-1)), -(offsety + (256 * (j - 1))))
							texture:SetTexture(texturename..(((j - 1) * numtexwide) + k))
							texture:Show()
						end
					end 
				end
			end

			-- Remove track checkbox tooltip
			WorldMapTrackQuest:SetScript("OnEnter", GameTooltip_Hide)
			WorldMapTrackQuest:SetHitRectInsets(0, 0 - WorldMapTrackQuestText:GetWidth(), 0, 0);

			-- Create reveal checkbox
			LeaPlusCB["MapRevealBox"] = CreateFrame('CheckButton', nil, WorldMapPositioningGuide, "OptionsCheckButtonTemplate")
			LeaPlusCB["MapRevealBox"]:SetHitRectInsets(0, -42, 0, 0);
			LeaPlusCB["MapRevealBox"]:SetSize(24, 24)
			LeaPlusCB["MapRevealBox"]:SetPoint("LEFT", WorldMapTrackQuestText, "RIGHT", 20, 0)

			LeaPlusCB["MapRevealBox.f"] = LeaPlusCB["MapRevealBox"]:CreateFontString(nil, 'OVERLAY', "GameFontNormal")
			LeaPlusCB["MapRevealBox.f"]:SetPoint("LEFT", 24, 0)
			LeaPlusCB["MapRevealBox.f"]:SetText("Reveal")
			LeaPlusCB["MapRevealBox.f"]:Show();

			-- Handle clicks
			LeaPlusCB["MapRevealBox"]:SetScript("OnClick", function()
				if LeaPlusCB["MapRevealBox"]:GetChecked() == 1 then
					LeaPlusLC["MapRevealBox"] = "On"
					if WorldMapFrame:IsShown() then
						RefMap()
					end
				else
					LeaPlusLC["MapRevealBox"] = "Off"
					if texcount > 0 then
						for i = 1, texcount do MapTex[i]:Hide()	end
						texcount = 0
					end
				end
			end)

			-- Set checkbox state
			LeaPlusCB["MapRevealBox"]:SetScript("OnShow", function()
				if LeaPlusLC["MapRevealBox"] == "On" then LeaPlusCB["MapRevealBox"]:SetChecked(true) else LeaPlusCB["MapRevealBox"]:SetChecked(false) end
			end)

			-- Update map
			hooksecurefunc("WorldMapFrame_Update", function()
				if WorldMapFrame:IsShown() and LeaPlusLC["MapRevealBox"] == "On" then
					RefMap();
				end
			end)

			----------------------------------------------------------------------
			-- Map pointer ring
			----------------------------------------------------------------------

			-- Hide map pointer ring
			WorldMapPing:HookScript("OnShow", function()
				if LeaPlusLC["MapRing"] == "On" then
					WorldMapPing:Hide()
				end
			end)

			----------------------------------------------------------------------
			-- Quest details
			----------------------------------------------------------------------

			local function ShowQuestDetails()
				QuestLogDetailFrame:ClearAllPoints()
				if LeaPlusLC["MapQuestLeft"] == "On" then
					QuestLogDetailFrame:SetPoint("TOPRIGHT", WorldMapFrame, "TOPLEFT", -10, 0)
				else
					QuestLogDetailFrame:SetPoint("TOPLEFT", WorldMapFrame, "TOPRIGHT", 10, 0)
				end
				QuestLogDetailFrame:Show()
			end

			-- Hook POI clicking function to show quest detail frame
			hooksecurefunc("WorldMapQuestPOI_OnClick", function(self)
				if LeaPlusLC["MapQuestBox"] == "On" then
					if not IsShiftKeyDown() and not IsControlKeyDown() then
						-- Get the quest log index position of the button that was clicked
						local cquest = self.quest.questLogIndex
						--local cid = self.quest.questId
						if cquest then
							-- Hide detail frame if quest hasn't changed (toggle)
							if cquest == GetQuestLogSelection() then
								if QuestLogDetailFrame:IsShown() then
									QuestLogDetailFrame:Hide();
									return
								end
							end
							-- Select the entry in the log
							SelectQuestLogEntry(cquest);
							-- Show and hide the quest log (forced update)
							if not QuestLogFrame:IsShown() then QuestLogFrame:Show();QuestLogFrame:Hide(); end
							-- Show the detail frame
							ShowQuestDetails();
						end
					end
				end
			end)

			-- When the map is closed, the quest detail should close too
			LeaPlusCB["MapRevealBox"]:SetScript("OnHide", function()
				if LeaPlusLC["MapQuestBox"] == "On" then
					QuestLogDetailFrame:Hide();
				end
			end)

			----------------------------------------------------------------------
			-- Cursor coordinates
			----------------------------------------------------------------------

			-- Create cursor coordinates frame (map)
			local Cmap = CreateFrame("FRAME", nil, WorldMapFrame)
			Cmap:SetWidth(38);	Cmap:SetHeight(16);
			Cmap:SetPoint("TOPLEFT", 16, -3)

			Cmap.x = Cmap:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall") 
			Cmap.x:SetAllPoints(); Cmap.x:SetJustifyH"LEFT";

			Cmap.y = Cmap:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall") 
			Cmap.y:SetPoint("LEFT", Cmap.x, "RIGHT", -6, 0);
			Cmap.y:SetJustifyH"LEFT";

			-- Initialise variables
			local vmapx, vmapy = 0, 0
			local mtimer = 0

			-- Cursor coordinates update function
			local function UpdateCursorCoords(self, elapsed)

				mtimer = mtimer + elapsed;

				while (mtimer > 0.1) do

					-- Show cursor coordinates
					local scale = WorldMapDetailFrame:GetEffectiveScale()
					local width = WorldMapDetailFrame:GetWidth()
					local height = WorldMapDetailFrame:GetHeight()
					local cenx, ceny = WorldMapDetailFrame:GetCenter()
					local x, y = GetCursorPosition()
					local vmapx = (x / scale - (cenx - (width/2))) / width
					local vmapy = (ceny + (height/2) - y / scale) / height		

					if (vmapx >= 0  and vmapy >= 0 and vmapx <=1 and vmapy <=1) then
						Cmap.x:SetFormattedText("%0.1f", (floor(vmapx * 1000 + 0.5)) / 10)
						Cmap.y:SetFormattedText("%0.1f", (floor(vmapy * 1000 + 0.5)) / 10)
					end

					mtimer = 0;

				end

			end

			-- Function to toggle cursor coordinates (run on startup and when option is clicked)
			local function RefreshCursorCoords()
				if LeaPlusLC["CursorCoords"] == "On" then
					Cmap:Show();
					Cmap:SetScript("OnUpdate", UpdateCursorCoords)
				else
					Cmap:Hide();
					Cmap:SetScript("OnUpdate", nil)
				end
			end

			----------------------------------------------------------------------
			-- Map modification functions (scale, opacity, position)
			----------------------------------------------------------------------

			-- Set map position
			local function RefreshMapPos()
				WorldMapFrame:ClearAllPoints();
				WorldMapFrame:SetPoint(LeaPlusLC["MapA"], LeaPlusLC["MapX"], LeaPlusLC["MapY"])
				WorldMapScreenAnchor:ClearAllPoints()
				WorldMapScreenAnchor:StartMoving();
				WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame);
				WorldMapScreenAnchor:StopMovingOrSizing();
				WorldMapFrame:SetUserPlaced(false)
				WorldMapScreenAnchor:SetUserPlaced(false)
				WorldMapFrame:SetToplevel(true)
			end

			-- Refresh the map with changes
			local function RefreshMapMod()
				-- Set map scale
				WorldMapFrame:SetScale(LeaPlusLC["LeaPlusMapScale"])
				-- Set map opacity
				WorldMapFrame_SetOpacity(LeaPlusLC["LeaPlusMapOpacity"])
				WORLDMAP_SETTINGS.opacity = LeaPlusLC["LeaPlusMapOpacity"];
				SetCVar("worldMapOpacity", LeaPlusLC["LeaPlusMapOpacity"]);
				-- Set map lock state
				if LeaPlusLC["MapLock"] == "On" then
					WORLDMAP_SETTINGS.locked = true
					SetCVar("lockedWorldMap", 1);
				else
					WORLDMAP_SETTINGS.locked = false
					SetCVar("lockedWorldMap", 0);
				end
				-- Set map ring state
				if LeaPlusLC["MapRing"] == "On" then
					WorldMapPing:Hide()
				end
				-- Map quest box
				if LeaPlusLC["MapQuestBox"] == "Off" then
					LeaPlusLC:LockItem(LeaPlusCB["MapQuestLeft"],true)
				else
					LeaPlusLC:LockItem(LeaPlusCB["MapQuestLeft"],false)
				end
			end

			-- Save map position after dragging it
			WorldMapTitleButton:HookScript("OnDragStop", function()
				LeaPlusLC["MapA"], void, void, LeaPlusLC["MapX"], LeaPlusLC["MapY"] = WorldMapFrame:GetPoint()
				WorldMapFrame:SetUserPlaced(false)
				WorldMapScreenAnchor:SetUserPlaced(false)
			end)

			-- Remove existing context menu (else it gets confusing)
			WorldMapTitleButton:RegisterForClicks("LeftButton")

			----------------------------------------------------------------------
			-- Map Panel
			----------------------------------------------------------------------

			-- Create map panel
			local SideMap = LeaPlusLC:CreateSidePanel("World Map", 164, 320)

			-- Add scale slider
			LeaPlusLC:MakeTx(SideMap, "Map Scale", 10, -60)
			LeaPlusLC:MakeSL(SideMap, "LeaPlusMapScale", "", 0.5, 2.7, 0.05, 10, -80, "%.2f")
			LeaPlusCB["LeaPlusMapScale"]:HookScript("OnValueChanged", RefreshMapMod)
			LeaPlusCB["LeaPlusMapScale"]:HookScript("OnMouseUp", ToggleMapSafe)
			LeaPlusCB["LeaPlusMapScale"]:HookScript("OnMouseWheel", ToggleMapSafe)

			-- Add opacity slider
			LeaPlusLC:MakeTx(SideMap, "Map Opacity", 10, -110)
			LeaPlusLC:MakeSL(SideMap, "LeaPlusMapOpacity", "", 0.0, 1.0, 0.1, 10, -130, "%.1f")
			LeaPlusCB["LeaPlusMapOpacity"]:HookScript("OnValueChanged", RefreshMapMod)

			-- Add cursor coordinates checkbox
			LeaPlusLC:MakeCB(SideMap, "CursorCoords", "Show cursor coords", 10, -160, "If checked, cursor coordinates will be shown at the topleft of the world map.", 2)
			LeaPlusCB["CursorCoords"]:HookScript("OnClick", RefreshCursorCoords)

			-- Add map ring checkbox
			LeaPlusLC:MakeCB(SideMap, "MapRing", "Hide player ring", 10, -180, "If checked, the animated ring that briefly appears around your location when the map is opened will be hidden.", 2)
			LeaPlusCB["MapRing"]:HookScript("OnClick", RefreshMapMod)

			-- Add lock checkbox
			LeaPlusLC:MakeCB(SideMap, "MapLock", "Lock map position", 10, -200, "If checked, the world map frame position will be locked and you will not be able to move it.\n\nIf unchecked, you will be able to move the map by dragging the title bar.  The map cannot be moved during combat.", 2)
			LeaPlusCB["MapLock"]:HookScript("OnClick", RefreshMapMod)

			-- Add quest details checkbox
			LeaPlusLC:MakeCB(SideMap, "MapQuestBox", "Show quest details", 10, -220, "If checked, clicking on quest objectives will show the quest details.", 2)
			LeaPlusCB["MapQuestBox"]:HookScript("OnClick", RefreshMapMod)

			-- Add quest details left side checkbox
			LeaPlusLC:MakeCB(SideMap, "MapQuestLeft", "On left side", 30, -240, "If checked, quest details will be shown on the left side of the map instead of the right.", 3)
			LeaPlusCB["MapQuestLeft"]:HookScript("OnClick", function()
				RefreshMapMod();
				if QuestLogDetailFrame:IsShown() then ShowQuestDetails() end
			end)

			-- Create save button
			LeaPlusLC:CreateButton("SaveMapBtn", SideMap, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
			LeaPlusCB["SaveMapBtn"]:SetScript("OnClick", function()
				SideMap:Hide();
				if WorldMapFrame:IsShown() then MiniMapWorldMapButton:Click(); end
				LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page5"]:Show();
			end)

			-- Create reset button
			LeaPlusLC:CreateButton("ResetMapBtn", SideMap, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
			LeaPlusCB["ResetMapBtn"]:SetScript("OnClick", function()
				LeaPlusLC["LeaPlusMapScale"] = 1.0
				LeaPlusLC["LeaPlusMapOpacity"] = 0.0
				LeaPlusLC["MapLock"] = "Off"
				LeaPlusLC["MapA"] = "TOPLEFT"
				LeaPlusLC["MapX"] = 10
				LeaPlusLC["MapY"] = -118
				LeaPlusLC["MapQuestBox"] = "On"
				LeaPlusLC["MapQuestLeft"] = "Off"
				LeaPlusLC["CursorCoords"] = "On"
				LeaPlusLC["MapRing"] = "Off"
				RefreshMapMod();
				RefreshMapPos();
				ToggleMapSafe();
				RefreshCursorCoords();
				SideMap:Hide(); SideMap:Show();
			end)

			-- Hide controls during combat
			SideMap:RegisterEvent("PLAYER_REGEN_DISABLED")
			SideMap:SetScript("OnEvent", SideMap.Hide)
						
			----------------------------------------------------------------------
			-- World map modification
			----------------------------------------------------------------------

			-- Hook map panel configuration button
			LeaPlusCB["MapOptBtn"]:HookScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					if IsShiftKeyDown() and IsControlKeyDown() then

						-- Top secret profile (ssh!)
						LeaPlusLC["LeaPlusMapScale"] = 1.75
						LeaPlusLC["LeaPlusMapOpacity"] = 0.0
						LeaPlusLC["MapLock"] = "Off"
						LeaPlusLC["MapA"] = "TOPLEFT"
						LeaPlusLC["MapX"] = 0
						LeaPlusLC["MapY"] = 0
						LeaPlusLC["CursorCoords"] = "On"
						LeaPlusLC["MapQuestBox"] = "On"
						LeaPlusLC["MapQuestLeft"] = "Off"
						LeaPlusLC["MapRing"] = "Off"
						RefreshMapMod();
						RefreshMapPos();
						RefreshCursorCoords();
						ToggleMapSafe();
						LeaPlusLC["PageF"]:Show();
						
					else

						LeaPlusLC:HideFrames();
						-- Open the map configuration panel
						SideMap:Show();
						-- Open the world map
						if not WorldMapFrame:IsShown() then MiniMapWorldMapButton:Click(); end

					end
				end
			end)

			-- Disable the sizing button
			WorldMapFrameSizeUpButton:Disable();

			-- Prevent map movement during combat
			local LeaPlusIsMapLocked
			LeaPlusCB["MapRevealBox"]:RegisterEvent("PLAYER_REGEN_DISABLED")
			LeaPlusCB["MapRevealBox"]:RegisterEvent("PLAYER_REGEN_ENABLED")
			LeaPlusCB["MapRevealBox"]:SetScript("OnEvent", function(self,event)
				if event == "PLAYER_REGEN_DISABLED" then
					WorldMapFrame:StopMovingOrSizing();
					LeaPlusIsMapLocked = WORLDMAP_SETTINGS.locked
					WORLDMAP_SETTINGS.locked = true
				else
					if LeaPlusIsMapLocked == false then
						WORLDMAP_SETTINGS.locked = LeaPlusIsMapLocked
					end
				end
			end)

			-- Preshow the map box to set initial values
			SideMap:Show(); SideMap:Hide();

			-- Set map position on startup
			RefreshMapPos();

			-- Set the map scale
			RefreshMapMod();

			-- Set cursor coordinates
			RefreshCursorCoords();

			WorldMapZoneMinimapDropDown:SetScript("OnEnter", nil);

		end

		----------------------------------------------------------------------
		-- Show volume control on character sheet
		----------------------------------------------------------------------

		if LeaPlusLC["ShowVolume"] == "On" then

			-- Function to update master volume
			local function MasterVolUpdate()
				if LeaPlusLC["ShowVolume"] == "On" then
					-- Set the volume
					SetCVar("Sound_MasterVolume", LeaPlusLC["LeaPlusMaxVol"]);
					-- Format the slider text
					LeaPlusCB["LeaPlusMaxVol"].f:SetFormattedText("%.0f", LeaPlusLC["LeaPlusMaxVol"] * 20)
				end
			end

			-- Create slider control
			LeaPlusLC["LeaPlusMaxVol"] = tonumber(GetCVar("Sound_MasterVolume"));
			LeaPlusLC:MakeSL(CharacterModelFrame, "LeaPlusMaxVol", "",	0, 1, 0.05, -34, -328, "%.2f")
			LeaPlusCB["LeaPlusMaxVol"]:SetWidth(64);

			-- Set slider control value when shown
			LeaPlusCB["LeaPlusMaxVol"]:SetScript("OnShow", function()
				LeaPlusCB["LeaPlusMaxVol"]:SetValue(GetCVar("Sound_MasterVolume"))
			end)

			-- Update volume when slider control is changed
			LeaPlusCB["LeaPlusMaxVol"]:HookScript("OnValueChanged", MasterVolUpdate);

			-- Dual layout
			local function SetVolumePlacement()
				if LeaPlusLC["ShowVolumeInFrame"] == "On" then
					LeaPlusCB["LeaPlusMaxVol"]:ClearAllPoints();
					LeaPlusCB["LeaPlusMaxVol"]:SetPoint("TOPLEFT", 72, -276)
				else
					LeaPlusCB["LeaPlusMaxVol"]:ClearAllPoints();
					LeaPlusCB["LeaPlusMaxVol"]:SetPoint("TOPLEFT", -34, -328)
				end
			end

			LeaPlusCB["LeaPlusMaxVol"]:SetScript('OnMouseDown', function(self, btn)
				if btn == "RightButton" and IsShiftKeyDown() then
					if LeaPlusLC["ShowVolumeInFrame"] == "On" then LeaPlusLC["ShowVolumeInFrame"] = "Off" else LeaPlusLC["ShowVolumeInFrame"] = "On" end
					SetVolumePlacement();
				end
			end)

			CharacterModelFrame:HookScript("OnShow",function()
				SetVolumePlacement();
			end)

		end

		----------------------------------------------------------------------
		-- Unclamp chat frame
		----------------------------------------------------------------------

		if LeaPlusLC["UnclampChat"] == "On" then

			-- Process normal chat frames
			for i = 1, NUM_CHAT_WINDOWS, 1 do
				_G["ChatFrame" .. i]:SetClampRectInsets(0, 0, 0, 0);
			end

			-- Process temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					_G[cf]:SetClampRectInsets(0, 0, 0, 0);
				end
			end)

		end

		----------------------------------------------------------------------
		-- Hide chat buttons
		----------------------------------------------------------------------

		if LeaPlusLC["NoChatButtons"] == "On" then

			-- Create hidden frame to store unwanted frames (more efficient than creating functions)
			local tframe = CreateFrame("FRAME")
			tframe:Hide()

			-- Function to add CTRL key and SHIFT key modifiers to mousescroll functionality
			local function AddChatModKeys(chtfrm)
				_G[chtfrm]:HookScript("OnMouseWheel", function(self, direction)
					if IsControlKeyDown() then
						if direction == 1 then self:ScrollToTop() else self:ScrollToBottom() end
					elseif IsShiftKeyDown() then 
						if direction == 1 then self:PageUp() else self:PageDown() end
					end
				end)
			end

			-- Function to hide chat buttons
			local function HideButtons(chtfrm)
				_G[chtfrm .. "ButtonFrameUpButton"]:SetParent(tframe)
				_G[chtfrm .. "ButtonFrameDownButton"]:SetParent(tframe)
				_G[chtfrm .. "ButtonFrameMinimizeButton"]:SetParent(tframe)
				_G[chtfrm .. "ButtonFrameUpButton"]:Hide();
				_G[chtfrm .. "ButtonFrameDownButton"]:Hide();
				_G[chtfrm .. "ButtonFrameMinimizeButton"]:Hide();
				_G[chtfrm .. "ButtonFrame"]:SetSize(0.1,0.1)
			end

			-- Function to highlight chat tabs and click to scroll to bottom
			local function HighlightTabs(chtfrm)
				-- Set position of bottom button
				_G[chtfrm .. "ButtonFrameBottomButtonFlash"]:SetTexture("Interface/BUTTONS/GRADBLUE.png")
				_G[chtfrm .. "ButtonFrameBottomButton"]:ClearAllPoints()
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetPoint("BOTTOM",_G[chtfrm .. "Tab"],0,-6)
				_G[chtfrm .. "ButtonFrameBottomButton"]:Show()
				_G[chtfrm .. "ButtonFrameBottomButtonFlash"]:SetAlpha(0.5)
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetWidth(_G[chtfrm .. "Tab"]:GetWidth()-10)
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetHeight(24)

				-- Resize bottom button according to tab size
				_G[chtfrm .. "Tab"]:SetScript("OnSizeChanged", function()
					for j = 1, NUM_CHAT_WINDOWS, 1 do
						-- Resize bottom button to tab width
						_G["ChatFrame" .. j .. "ButtonFrameBottomButton"]:SetWidth(_G["ChatFrame" .. j .. "Tab"]:GetWidth()-10)
					end
				end)

				-- Remove click from the bottom button
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetScript("OnClick", nil)

				-- Remove textures
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetNormalTexture("")
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetHighlightTexture("")
				_G[chtfrm .. "ButtonFrameBottomButton"]:SetPushedTexture("")

				-- Always scroll to bottom when clicking a tab
				_G[chtfrm .. "Tab"]:HookScript("OnClick", function(self,arg1)
					if arg1 == "LeftButton" then
						_G[chtfrm]:ScrollToBottom();
					end
				end)

			end

			-- Enable mouse scrolling and prevent changes
			SetCVar("chatMouseScroll", "1")
			InterfaceOptionsSocialPanelChatMouseScroll:Disable()
			InterfaceOptionsSocialPanelChatMouseScrollText:SetAlpha(0.3)
			InterfaceOptionsSocialPanelChatMouseScroll_SetScrolling("1")

			-- Hide chat menu button and friends button
			ChatFrameMenuButton:SetParent(tframe)
			FriendsMicroButton:SetParent(tframe)

			-- Set options for normal chat frames
			for i = 1, NUM_CHAT_WINDOWS, 1 do
				AddChatModKeys("ChatFrame" .. i);
				HideButtons("ChatFrame" .. i);
				HighlightTabs("ChatFrame" .. i)
			end

			-- Do the functions above for temporary chat frames
			hooksecurefunc("FCF_OpenTemporaryWindow", function(chatType)
				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then
					-- Set options for temporary frame
					AddChatModKeys(cf);
					HideButtons(cf)
					HighlightTabs(cf)
					-- Resize flashing alert to match tab width
					_G[cf .. "Tab"]:SetScript("OnSizeChanged", function()
						_G[cf .. "ButtonFrameBottomButton"]:SetWidth(_G[cf .. "Tab"]:GetWidth()-10)
					end)
				end
			end)

			-- Hide conversation buttons that appear during battle.net chats
			hooksecurefunc("BNConversationButton_UpdateAttachmentPoint", function(self)
				if self:IsShown() then
					self:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- L42: Frame Customisation
		----------------------------------------------------------------------

		-- Frame Movement
		if LeaPlusLC["FrmEnabled"] == "On" then

			-- Lock the player and target frames
			PlayerFrame_SetLocked(true)
			TargetFrame_SetLocked(true)

			-- Remove integrated movement functions to avoid conflicts
			PlayerFrame_ResetUserPlacedPosition = function() LeaPlusLC:Print("Use Leatrix Plus to reset that frame.") end
			TargetFrame_ResetUserPlacedPosition = function() LeaPlusLC:Print("Use Leatrix Plus to reset that frame.") end
			PlayerFrame_SetLocked = function() LeaPlusLC:Print("Use Leatrix Plus to move that frame.") end
			TargetFrame_SetLocked = function() LeaPlusLC:Print("Use Leatrix Plus to move that frame.") end

			-- Create frame table (used for local traversal)
			local FrameTable = {DragPlayerFrame = PlayerFrame, DragTargetFrame = TargetFrame, DragWorldStateAlwaysUpFrame = WorldStateAlwaysUpFrame, DragGhostFrame = GhostFrame, DragMirrorTimer1 = MirrorTimer1};

			-- Create main table structure in saved variables if it doesn't exist
			if (LeaPlusDB["Frames"]) == nil then
				LeaPlusDB["Frames"] = {}
			end

			-- Create frame based table structure in saved variables if it doesn't exist and set initial scales
			for k,v in pairs(FrameTable) do
				local vf = v:GetName();
				-- Create frame table structure if it doesn't exist
				if not LeaPlusDB["Frames"][vf] then
					LeaPlusDB["Frames"][vf] = {}
				end
				-- Set saved scale value to default if it doesn't exist
				if not LeaPlusDB["Frames"][vf]["Scale"] then
					LeaPlusDB["Frames"][vf]["Scale"] = 1.00;
				end
				-- Set frame scale to saved value
				_G[vf]:SetScale(LeaPlusDB["Frames"][vf]["Scale"])
			end

			-- Set cached status
			local function LeaPlusFramesSaveCache(frame)
				if frame == "PlayerFrame" or frame == "TargetFrame" then
					_G[frame]:SetUserPlaced(true);
				else
					_G[frame]:SetUserPlaced(false);
				end
			end

			-- Set frames to manual values
			local function LeaFramesSetPos(frame, point, parent, relative, xoff, yoff)
				frame:SetMovable(true);
				frame:ClearAllPoints();
				frame:SetPoint(point, parent, relative, xoff, yoff)
			end

			-- Set frames to default values
			local function LeaPlusFramesDefaults()
				LeaFramesSetPos(PlayerFrame				, "TOPLEFT"	, UIParent, "TOPLEFT"	, -19, -4)
				LeaFramesSetPos(TargetFrame				, "TOPLEFT"	, UIParent, "TOPLEFT"	, 250, -4)
				LeaFramesSetPos(WorldStateAlwaysUpFrame	, "TOP"		, UIParent, "TOP"		, -5, -15)
				LeaFramesSetPos(GhostFrame				, "TOP"		, UIParent, "TOP"		, -5, -29)
				LeaFramesSetPos(MirrorTimer1			, "TOP"		, UIParent, "TOP"		, -5, -96)
			end

			-- Create frame customisation side panel
			local SideFrames = LeaPlusLC:CreateSidePanel("Frames", 164, 280)

			-- Create frame checkboxes
			local function LeaPlusFramesCB(x, y, frame, text, tip)
				local cbox = CreateFrame('CheckButton', nil, SideFrames, 'ChatConfigCheckButtonTemplate')
				cbox:SetPoint("TOPLEFT", x, y)
				cbox:SetHitRectInsets(0, -70, 0, 0);

				-- Checkbox labels
				cbox.t = cbox:CreateFontString(nil, "BACKGROUND", "GameTooltipText") 
					cbox.t:SetPoint("LEFT",30,0) 
					cbox.t:SetText(text)

				-- Process clicks
				cbox:SetScript('OnClick', function()
					if cbox:GetChecked() == nil then LeaPlusLC[frame]:Hide(); end
					if cbox:GetChecked() == 1 then LeaPlusLC[frame]:Show(); end					
				end)

				-- Set default checkbox state
				SideFrames:HookScript("OnShow", function() 
					cbox:SetChecked(true)
				end)

				-- Set tooltip
				cbox:SetScript("OnEnter", function()
					if LeaPlusLC["PlusShowTips"] == "On" then
						GameTooltip:SetOwner(cbox, "ANCHOR_LEFT", -10, -50)
						GameTooltip:SetText(tip, nil, nil, nil, nil, true)
					end
				end)

			end

			-- Create checkboxes
			LeaPlusFramesCB(10, -60, "DragPlayerFrame", "Player frame", "Click to toggle the player frame overlay.\n\nToggling the overlay frames is useful if you wish to access frames that are underneath.")
			LeaPlusFramesCB(10, -80, "DragTargetFrame", "Target frame", "Click to toggle the target frame overlay.\n\nToggling the overlay frames is useful if you wish to access frames that are underneath.")
			LeaPlusFramesCB(10, -100, "DragWorldStateAlwaysUpFrame", "World state", "Click to toggle the world state frame overlay.\n\nThe world state frame is most commonly used for keeping score (such as in battlegrounds).\n\nToggling the overlay frames is useful if you wish to access frames that are underneath.")
			LeaPlusFramesCB(10, -120, "DragGhostFrame", "Ghost frame", "Click to toggle the ghost frame overlay.\n\nThe ghost frame appears when your character is a ghost.  It allows you to return to the spirit healer.\n\nToggling the overlay frames is useful if you wish to access frames that are underneath.")
			LeaPlusFramesCB(10, -140, "DragMirrorTimer1", "Timer bar", "Click to toggle the mirror timer bar overlay.\n\nThe mirror timer bar is used for various activities such as underwater breathing.\n\nNote that not all timer bars use this frame.\n\nToggling the overlay frames is useful if you wish to access frames that are underneath.")

			-- Variable used to store currently selected frame
			local currentframe

			-- Create scale title
			LeaPlusLC:MakeTx(SideFrames, "Selected Frame Scale", 10, -180)
			
			-- Set initial slider value (will be changed when drag frames are selected)
			LeaPlusLC["FrameScale"] = 1.00;

			-- Create scale slider
			LeaPlusLC:MakeSL(SideFrames, "FrameScale", "", 0.5, 3.0, 0.05, 10, -200, "%.2f")
			LeaPlusCB["FrameScale"]:HookScript("OnValueChanged", function(self, value)
				if currentframe then -- If a frame is selected
					-- Set real and drag frame scale
					LeaPlusDB["Frames"][currentframe]["Scale"] = value;
					_G[currentframe]:SetScale(LeaPlusDB["Frames"][currentframe]["Scale"]);
					LeaPlusLC["Drag" .. currentframe]:SetScale(LeaPlusDB["Frames"][currentframe]["Scale"]);
					-- If target frame scale is changed, also change combo point frame
					if currentframe == "TargetFrame" then
						ComboFrame:SetScale(LeaPlusDB["Frames"]["TargetFrame"]["Scale"]);
					end
				end
			end)

			-- Set initial scale slider state and value
			LeaPlusCB["FrameScale"]:HookScript("OnShow", function()
				if not currentframe then
					-- No frame selected so select the player frame
					currentframe = PlayerFrame:GetName()
					LeaPlusLC["DragPlayerFrame"].t:SetTexture(0.0, 1.0, 0.0,0.5)
				end
				-- Set the scale slider value to the selected frame
				LeaPlusCB["FrameScale"]:SetValue(LeaPlusDB["Frames"][currentframe]["Scale"]);
			end)

			-- Create save button
			LeaPlusLC:CreateButton("SaveFramesBtn", SideFrames, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
			LeaPlusCB["SaveFramesBtn"]:SetScript("OnClick", function()
				-- Hide outer control frame
				SideFrames:Hide();
				-- Hide drag frames
				for k, void in pairs(FrameTable) do
					LeaPlusLC[k]:Hide();
				end
				-- Show options panel at frame section
				LeaPlusLC["PageF"]:Show();
				LeaPlusLC["Page5"]:Show();
			end)

			-- Create reset button
			LeaPlusLC:CreateButton("ResetFramesBtn", SideFrames, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
			LeaPlusCB["ResetFramesBtn"]:SetScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					-- If player is in combat, print error and stop
					return
				else
					-- Set frames to default positions (presets)
					LeaPlusFramesDefaults();
					for k,v in pairs(FrameTable) do
						local vf = v:GetName()
						-- Store frame locations
						LeaPlusDB["Frames"][vf]["Point"], void, LeaPlusDB["Frames"][vf]["Relative"], LeaPlusDB["Frames"][vf]["XOffset"], LeaPlusDB["Frames"][vf]["YOffset"] = _G[vf]:GetPoint();
						-- Reset real frame scales and save them
						LeaPlusDB["Frames"][vf]["Scale"] = 1.00;
						_G[vf]:SetScale(LeaPlusDB["Frames"][vf]["Scale"]);
						-- Reset drag frame scales
						LeaPlusLC[k]:SetScale(LeaPlusDB["Frames"][vf]["Scale"]);
					end
					-- Set combo frame scale to match target frame scale
					ComboFrame:SetScale(LeaPlusDB["Frames"]["TargetFrame"]["Scale"]);
					-- Set the scale slider value to the selected frame scale
					LeaPlusCB["FrameScale"]:SetValue(LeaPlusDB["Frames"][currentframe]["Scale"]);
				end
			end)

			-- Save frame positions
			local function SaveAllFrames()
				for k, v in pairs(FrameTable) do
					local vf = v:GetName();
					-- Stop real frames from moving
					v:StopMovingOrSizing();
					-- Save frame positions
					LeaPlusDB["Frames"][vf]["Point"], void, LeaPlusDB["Frames"][vf]["Relative"], LeaPlusDB["Frames"][vf]["XOffset"], LeaPlusDB["Frames"][vf]["YOffset"] = v:GetPoint();
					LeaPlusFramesSaveCache(vf)
				end
			end

			-- Prevent changes during combat
			SideFrames:RegisterEvent("PLAYER_REGEN_DISABLED")
			SideFrames:SetScript("OnEvent", function()
				-- Hide controls frame
				SideFrames:Hide();
				-- Hide drag frames
				for k,void in pairs(FrameTable) do
					LeaPlusLC[k]:Hide();
				end
				-- Save frame positions
				SaveAllFrames();
			end)

			-- Create drag frames
			local function LeaPlusMakeDrag(dragframe,realframe)

				local dragframe = CreateFrame("Frame", nil);
				LeaPlusLC[dragframe] = dragframe
				dragframe:SetSize(realframe:GetSize())
				dragframe:SetPoint("TOP", realframe, "TOP", 0, 2.5)

				dragframe:SetBackdropColor(0.0, 0.5, 1.0);
				dragframe:SetBackdrop({ 
					edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
					tile = false, tileSize = 0, edgeSize = 16,
					insets = { left = 0, right = 0, top = 0, bottom = 0 }});
				dragframe:SetToplevel(true)

				-- Clamp frame to screen by default
				realframe:SetClampedToScreen(true)

				-- Set frame specific clamps
				if realframe:GetName() == "PlayerFrame" then
					-- Allow player frame to be pushed off the left and top edge
					realframe:SetClampRectInsets(50, 0, -20, 0)
				end

				if realframe:GetName() == "TargetFrame" then
					-- Allow target frame to be pushed off the top edge
					realframe:SetClampRectInsets(0, 0, -20, 0)
				end

				-- What does the fox say?
				dragframe:Hide()
				realframe:SetMovable(true);

				-- Click handler
				dragframe:SetScript("OnMouseDown", function(self, btn)

					-- Start dragging if left clicked
					if btn == "LeftButton" then
						realframe:StartMoving()
					end

					-- Set all drag frames to blue then tint the selected frame to green
					for k,v in pairs(FrameTable) do
						LeaPlusLC[k].t:SetTexture(0.0, 0.5, 1.0,0.5)
					end
					dragframe.t:SetTexture(0.0, 1.0, 0.0,0.5)

					-- Set currentframe variable to selected frame and set the scale slider value
					currentframe = realframe:GetName();
					LeaPlusCB["FrameScale"]:SetValue(LeaPlusDB["Frames"][currentframe]["Scale"]);

				end)

				dragframe:SetScript("OnMouseUp", function()
					-- Save frame positions
					SaveAllFrames();
				end)
	
				dragframe.t = dragframe:CreateTexture()
				dragframe.t:SetAllPoints()
				dragframe.t:SetTexture(0.0, 0.5, 1.0,0.5)
				dragframe.t:SetAlpha(0.5)

				dragframe.f = dragframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
				dragframe.f:SetPoint('CENTER', 0, 0)

				-- Add titles
				if realframe:GetName() == "PlayerFrame" 			then dragframe.f:SetText("Player") end
				if realframe:GetName() == "TargetFrame" 			then dragframe.f:SetText("Target") end
				if realframe:GetName() == "WorldStateAlwaysUpFrame" then dragframe.f:SetText("World State") end
				if realframe:GetName() == "MirrorTimer1" 			then dragframe.f:SetText("Timer") end
				if realframe:GetName() == "GhostFrame" 				then dragframe.f:SetText("Ghost") end
				return LeaPlusLC[dragframe]

			end
			
			for k,v in pairs(FrameTable) do
				LeaPlusLC[k] = LeaPlusMakeDrag(k,v)
			end

			-- Set frame scales
			for k,v in pairs(FrameTable) do
				local vf = v:GetName();
				_G[vf]:SetScale(LeaPlusDB["Frames"][vf]["Scale"]);
				LeaPlusLC[k]:SetScale(LeaPlusDB["Frames"][vf]["Scale"]);
			end
			ComboFrame:SetScale(LeaPlusDB["Frames"]["TargetFrame"]["Scale"]);

			-- Load defaults first then overwrite with saved values if they exist
			LeaPlusFramesDefaults();
			if LeaPlusDB["Frames"] then
				for k,v in pairs(FrameTable) do
					local vf = v:GetName()
					if LeaPlusDB["Frames"][vf] then
						if LeaPlusDB["Frames"][vf]["Point"] and LeaPlusDB["Frames"][vf]["Relative"] and LeaPlusDB["Frames"][vf]["XOffset"] and LeaPlusDB["Frames"][vf]["YOffset"] then
							LeaPlusFramesSaveCache(vf)
							_G[vf]:ClearAllPoints();
							_G[vf]:SetPoint(LeaPlusDB["Frames"][vf]["Point"], UIParent, LeaPlusDB["Frames"][vf]["Relative"], LeaPlusDB["Frames"][vf]["XOffset"], LeaPlusDB["Frames"][vf]["YOffset"])
						end
					end
				end
			end

			-- Add move button
			LeaPlusCB["MoveFramesButton"]:SetScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					-- Top secret frame profile (ssh!)
					if (IsShiftKeyDown()) and (IsControlKeyDown()) then
						-- Manual profile
						LeaFramesSetPos(PlayerFrame				, "TOPLEFT"	, UIParent, "TOPLEFT"	,	"-35"	, "-14")
						LeaFramesSetPos(TargetFrame				, "TOPLEFT"	, UIParent, "TOPLEFT"	,	"190"	, "-14")
						LeaFramesSetPos(GhostFrame				, "CENTER"	, UIParent, "CENTER"	,	"3"		, "-142")
						LeaFramesSetPos(WorldStateAlwaysUpFrame	, "TOP"		, UIParent, "TOP"		,	"-40"	, "-530")
						LeaFramesSetPos(MirrorTimer1			, "TOP"		, UIParent, "TOP"		,	"0"		, "-120")
						LeaPlusDB["Frames"]["PlayerFrame"]["Scale"] = 1.20;
						PlayerFrame:SetScale(LeaPlusDB["Frames"]["PlayerFrame"]["Scale"]);
						LeaPlusLC["DragPlayerFrame"]:SetScale(LeaPlusDB["Frames"]["PlayerFrame"]["Scale"]);
						LeaPlusDB["Frames"]["TargetFrame"]["Scale"] = 1.20;
						TargetFrame:SetScale(LeaPlusDB["Frames"]["TargetFrame"]["Scale"]);
						LeaPlusLC["DragTargetFrame"]:SetScale(LeaPlusDB["Frames"]["TargetFrame"]["Scale"]);
						-- Save locations
						for k,v in pairs(FrameTable) do
							local vf = v:GetName();
							LeaPlusDB["Frames"][vf]["Point"], void, LeaPlusDB["Frames"][vf]["Relative"], LeaPlusDB["Frames"][vf]["XOffset"], LeaPlusDB["Frames"][vf]["YOffset"] = _G[vf]:GetPoint();
							LeaPlusFramesSaveCache(vf);
						end
					else
						-- Show mover frame
						SideFrames:Show();
						LeaPlusLC:HideFrames();

						-- Find out if the UI has a non-standard scale
						if GetCVar("useuiscale") == "1" then
							LeaPlusLC["gscale"] = GetCVar("uiscale")
						else
							LeaPlusLC["gscale"] = 1
						end

						-- Set all scaled sizes and show drag frames
						for k,v in pairs(FrameTable) do
							LeaPlusLC[k]:SetWidth(v:GetWidth() * LeaPlusLC["gscale"])
							LeaPlusLC[k]:SetHeight(v:GetHeight() * LeaPlusLC["gscale"])
							LeaPlusLC[k]:Show();
						end

						-- Set specific scaled sizes for stubborn frames
						LeaPlusLC["DragWorldStateAlwaysUpFrame"]:SetSize(300 * LeaPlusLC["gscale"], 50 * LeaPlusLC["gscale"]);
						LeaPlusLC["DragMirrorTimer1"]:SetSize(206 * LeaPlusLC["gscale"], 50 * LeaPlusLC["gscale"]);
						LeaPlusLC["DragGhostFrame"]:SetSize(130 * LeaPlusLC["gscale"], 46 * LeaPlusLC["gscale"]);
					end
				end
			end)
		end

		-- Release memory
		LeaPlusLC.Variable = nil

	end

----------------------------------------------------------------------
--	L50: Player (only runs once)
----------------------------------------------------------------------

	function LeaPlusLC:Player()

		----------------------------------------------------------------------
		-- Fix Blizzard's taint issue when cancelling options during combat
		----------------------------------------------------------------------

		-- Remove the cancel button from the interface options frame
		InterfaceOptionsFrameCancel:Hide()
		InterfaceOptionsFrameOkay:SetAllPoints(InterfaceOptionsFrameCancel)

		-- Make clicking cancel the same as clicking okay
		InterfaceOptionsFrameCancel:SetScript("OnClick", function()
			InterfaceOptionsFrameOkay:Click()
		end)

		----------------------------------------------------------------------
		--	Move chat editbox to top
		----------------------------------------------------------------------

		if LeaPlusLC["MoveChatEditBoxToTop"] == "On" then

			-- Set options for normal chat frames
			for i = 1, NUM_CHAT_WINDOWS, 1 do
				-- Position the editbox
				_G["ChatFrame" .. i .. "EditBox"]:ClearAllPoints();
				_G["ChatFrame" .. i .. "EditBox"]:SetPoint("TOPLEFT", _G["ChatFrame" .. i], 0, 0);
				_G["ChatFrame" .. i .. "EditBox"]:SetWidth(_G["ChatFrame" .. i]:GetWidth());

				-- Ensure editbox width matches chatframe width
				_G["ChatFrame" .. i]:HookScript("OnSizeChanged", function()
					_G["ChatFrame" .. i .. "EditBox"]:SetWidth(_G["ChatFrame" .. i]:GetWidth())
				end)
			end

			-- Do the functions above for other chat frames (pet battles, whispers, etc)
			hooksecurefunc("FCF_OpenTemporaryWindow", function()

				local cf = FCF_GetCurrentChatFrame():GetName() or nil
				if cf then

					-- Position the editbox
					_G[cf .. "EditBox"]:ClearAllPoints();
					_G[cf .. "EditBox"]:SetPoint("TOPLEFT", cf, "TOPLEFT", 0, 0);
					_G[cf .. "EditBox"]:SetWidth(_G[cf]:GetWidth());

					-- Ensure editbox width matches chatframe width
					_G[cf]:HookScript("OnSizeChanged", function()
						_G[cf .. "EditBox"]:SetWidth(_G[cf]:GetWidth())
					end)

				end
			end)

		end

		----------------------------------------------------------------------
		-- Automatically toggle nameplates
		----------------------------------------------------------------------

		if LeaPlusDB["AutoEnName"] == "On" then -- Checks global

			-- Create side panel
			local EnPanel = LeaPlusLC:CreateSidePanel("Enemy Plates", 164, 230)

			LeaPlusLC:MakeTx(EnPanel, "Options", 10, -60)
			LeaPlusLC:MakeCB(EnPanel, "AutoEnPets", "Show pets", 10, -80, "If checked, nameplates will be toggled automatically for enemy pets.", 2)
			LeaPlusLC:MakeCB(EnPanel, "AutoEnGuardians", "Show guardians", 10, -100, "If checked, nameplates will be toggled automatically for enemy guardians.", 2)
			LeaPlusLC:MakeCB(EnPanel, "AutoEnTotems", "Show totems", 10, -120, "If checked, nameplates will be toggled automatically for enemy totems.", 2)
			LeaPlusLC:MakeCB(EnPanel, "AutoEnClassCol", "Show class color", 10, -140, "If checked, enemy nameplates will be shown in class color.", 2)

			-- Create save button
			LeaPlusLC:CreateButton("SaveEnPanelBtn", EnPanel, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
			LeaPlusCB["SaveEnPanelBtn"]:SetScript("OnClick", function()
				EnPanel:Hide();
				LeaPlusLC["PageF"]:Show();
				LeaPlusLC["Page6"]:Show();
				return
			end)

			-- Create reset button
			LeaPlusLC:CreateButton("ResetEnPanelBtn", EnPanel, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
			LeaPlusCB["ResetEnPanelBtn"]:SetScript("OnClick", function()
				LeaPlusLC["AutoEnPets"] = "On"
				LeaPlusLC["AutoEnGuardians"] = "On"
				LeaPlusLC["AutoEnTotems"] = "On"
				LeaPlusLC["AutoEnClassCol"] = "Off"
				EnPanel:Hide(); EnPanel:Show();
				LeaPlusLC:EnPlateFunc();
			end)

			-- Handler for options panel ? button
			LeaPlusCB["ModEnPanelBtn"]:SetScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Private profile
						LeaPlusLC["AutoEnPets"] = "On"
						LeaPlusLC["AutoEnGuardians"] = "On"
						LeaPlusLC["AutoEnTotems"] = "On"
						LeaPlusLC["AutoEnClassCol"] = "Off"
						LeaPlusLC:EnPlateFunc();
					else
						EnPanel:Show();
						LeaPlusLC:HideFrames();
					end
				end
			end)

			-- Hide panel if Blizzard options are shown
			EnPanel:HookScript("OnUpdate", function()
				if InterfaceOptionsFrame:IsShown() then 
					EnPanel:Hide() 
				end
			end)

			-- Hide panel if combat starts (to prevent CVAR taint)
			EnPanel:RegisterEvent("PLAYER_REGEN_DISABLED")
			EnPanel:SetScript("OnEvent", EnPanel.Hide)

			-- Function to set console variables
			local function EnPlateFunc()
				if LeaPlusLC["AutoEnPets"] == "On" 		then SetCVar("nameplateShowEnemyPets", 1) else SetCVar("nameplateShowEnemyPets", 0) end
				if LeaPlusLC["AutoEnGuardians"] == "On" then SetCVar("nameplateShowEnemyGuardians", 1) else SetCVar("nameplateShowEnemyGuardians", 0) end
				if LeaPlusLC["AutoEnTotems"] == "On" 	then SetCVar("nameplateShowEnemyTotems", 1) else SetCVar("nameplateShowEnemyTotems", 0) end
				if LeaPlusLC["AutoEnClassCol"] == "On" 	then SetCVar("ShowClassColorInNameplate", 1) else SetCVar("ShowClassColorInNameplate", 0) end
			end

			-- Give function a file level scope
			LeaPlusLC.EnPlateFunc = EnPlateFunc

			-- Hook checkbox controls
			LeaPlusCB["AutoEnPets"]:HookScript("OnClick", EnPlateFunc)
			LeaPlusCB["AutoEnGuardians"]:HookScript("OnClick", EnPlateFunc)
			LeaPlusCB["AutoEnTotems"]:HookScript("OnClick", EnPlateFunc)
			LeaPlusCB["AutoEnClassCol"]:HookScript("OnClick", EnPlateFunc)

			-- Set console variables on startup
			EnPlateFunc()

			-- Disable Blizzard options on startup
			InterfaceOptionsNamesPanelUnitNameplatesEnemies:Disable()

			-- Disable Blizzard options for enemy nameplates (alternative to removing dependent controls)
			local function BlizzOptHide()
				-- If enemy pets checkbox is enabled, disable all controls
				while (InterfaceOptionsNamesPanelUnitNameplatesEnemyPets:IsEnabled()) do
					InterfaceOptionsNamesPanelUnitNameplatesEnemies:Disable()
					InterfaceOptionsNamesPanelUnitNameplatesEnemyPets:Disable()
					InterfaceOptionsNamesPanelUnitNameplatesEnemyGuardians:Disable()
					InterfaceOptionsNamesPanelUnitNameplatesEnemyTotems:Disable()
					InterfaceOptionsNamesPanelUnitNameplatesNameplateClassColors:Disable()
				end
			end

			InterfaceOptionsNamesPanel:HookScript("OnUpdate", BlizzOptHide)

			-- Enable automatic enemy nameplate toggle
			local f = CreateFrame("Frame")
			f:RegisterEvent("PLAYER_REGEN_DISABLED")
			f:RegisterEvent("PLAYER_REGEN_ENABLED")
			f:SetScript("OnEvent", function(self, event)
				SetCVar("nameplateShowEnemies", event == "PLAYER_REGEN_DISABLED" and 1 or 0)
			end)

			-- Run combat check on startup
			SetCVar("nameplateShowEnemies", UnitAffectingCombat("player") and 1 or 0)

		end

		----------------------------------------------------------------------
		-- Block Battle.net friend requests
		----------------------------------------------------------------------

		if LeaPlusDB["ManageBnetReq"] == "On" then -- Checks global

			-- Function to decline friend requests
			local function DeclineReqs()
				if LeaPlusLC["BlockBnetReq"] == "On" then
					-- Hide chat message
					SetCVar("showToastFriendRequest", "0")
					-- Decline friend request
					for i = BNGetNumFriendInvites(), 1, -1 do
						local id, player = BNGetFriendInviteInfo(i)
						if id and player then
							BNDeclineFriendInvite(id)
							LeaPlusLC:Print("Friend request from " .. player .. " declined.")
						end
					end
				else
					-- Show chat message
					SetCVar("showToastFriendRequest", "1")
				end
			end

			-- Manage friend request toast frames
			hooksecurefunc("BNToastFrame_Show", function()
				if LeaPlusLC["BlockBnetReq"] == "On" then
					if BNToastFrame.toastType == 4 or BNToastFrame.toastType == 5 then
						BNToastFrame_Close()
					end
				end
			end)

			-- Manage friend requests as they happen
			local DecEvt = CreateFrame("FRAME")
			DecEvt:RegisterEvent("BN_FRIEND_INVITE_ADDED")
			DecEvt:SetScript("OnEvent", DeclineReqs)

			-- Manage friend requests on startup
			DeclineReqs()

			-- Run friend decline function when block checkbox clicked
			LeaPlusCB["BlockBnetReq"]:HookScript("OnClick", DeclineReqs)

		end

		----------------------------------------------------------------------
		-- Hide the combat log
		----------------------------------------------------------------------

		if LeaPlusDB["NoCombatLogTab"] == "On" then -- Checks global

			-- Reload UI if chat windows are reset by the user
			hooksecurefunc("FCF_ResetChatWindows", ReloadUI)

			-- Ensure combat log is docked
			if ChatFrame2.isDocked then 
	
				-- Function to setup the combat log
				local function SetupCombat()

					ChatFrame2Tab:SetPoint("BOTTOMLEFT", ChatFrame1Tab, "BOTTOMRIGHT", 0, 0)

					if ChatFrame2Tab:IsMouseEnabled() == nil and 
						ChatFrame2Tab:GetText() == nil and
						ChatFrame2Tab:GetScale() < 1 and
						ChatFrame2Tab:GetWidth() < 1 and
						ChatFrame2Tab:GetHeight() < 1 then
					else
						ChatFrame2Tab:EnableMouse(false)
						ChatFrame2Tab:SetText("")
						ChatFrame2Tab:SetScale(0.01)
						ChatFrame2Tab:SetWidth(0.01)
						ChatFrame2Tab:SetHeight(0.01)		
					end

				end

				-- Setup combat log at startup
				SetupCombat()

				-- Run script when tab 3 is visible
				ChatFrame3Tab:SetScript("OnShow", function() 
					SetupCombat() 
					ChatFrame3Tab:SetScript("OnShow", nil) 
				end)

				-- Run script when tabs are assigned by the client
				hooksecurefunc("FCF_SetTabPosition", SetupCombat)

			else

				-- If combat log is undocked, do nothing (can't dock it as doing so taints the UI)
				LeaPlusLC:Print("Combat log cannot be hidden while undocked.")

			end

		end

		----------------------------------------------------------------------
		-- Dark Soil alert
		----------------------------------------------------------------------

		if LeaPlusDB["SoilAlert"] == "On" then -- Checks global

			-- Quit if best friend (exalted) rep with all of the Tiller factions
			local tillergroup = {Jogu = 1273, Ella = 1275, Hillpaw = 1276, CheeChee = 1277, Sho = 1278, Haohan = 1279, Tina = 1280, Gina = 1281, Fish = 1282, Fung = 1283}
			local tillerdone = 0

			for i, v in pairs(tillergroup) do
				-- Get rep for each faction ID
				local tillerind = select(3, GetFactionInfoByID(v)) or 0
				-- If rep isn't exalted, set tillerdone to 9
				if tillerind then
					if tillerind ~= 6 then
						tillerdone = 9
					end
				end
			end

			-- If tillerdone is 9, some rep isn't exalted so we need the alert
			if tillerdone == 9 then
				-- Hook tooltip to check for Dark Soil (En, Fr, De, Es, It, Kr, Ru, CN, TW, Br)
				GameTooltip:HookScript("OnShow", function()
					if GetMouseFocus() ~= WorldFrame then return end
					if UnitExists("mouseover") then return end
					local key = _G["GameTooltipTextLeft1"]:GetText() or ""
					if key == "Dark Soil" or key == "Terre sombre" or key == "Dunkle Erde" or key == "Tierra oscura" or key == "Terreno Smosso" or key == "검은 토양" or key == "Темная земля" or key == "黑色泥土" or key == "深色土壤" or key == "Solo Negro" then
						PlaySoundFile("Sound\\Interface\\RaidWarning.ogg"); 
					end
				end)
			end

		end

		----------------------------------------------------------------------
		-- Viewport (added late in the loading process)
		----------------------------------------------------------------------

		if LeaPlusDB["ViewPortEnable"] == "On" then -- Checks global

			-- Store original functions so they can be recalled later
			local origWFClear = WorldFrame.ClearAllPoints
			local origWFSet = WorldFrame.SetPoint

			-- Create dummy function for preventing movement of WorldFrame
			local function WFdummy() return true end

			-- Create static textures
			local BordTop = WorldFrame:CreateTexture(nil, "ARTWORK");
			local BordBot = WorldFrame:CreateTexture(nil, "ARTWORK");
			local BordLeft = WorldFrame:CreateTexture(nil, "ARTWORK");
			local BordRight = WorldFrame:CreateTexture(nil, "ARTWORK");

			BordTop:SetTexture(0, 0, 0, 1); 
			BordBot:SetTexture(0, 0, 0, 1);
			BordLeft:SetTexture(0, 0, 0, 1);
			BordRight:SetTexture(0, 0, 0, 1);

			BordTop:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
			BordTop:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0);
			BordBot:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0);
			BordBot:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0);

			BordLeft:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
			BordLeft:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0);
			BordRight:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0);
			BordRight:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0);

			local function RefreshViewport()

				-- Ensure original functions are used since we want WorldFrame to be positioned
				WorldFrame.ClearAllPoints = origWFClear
				WorldFrame.SetPoint = origWFSet

				-- Position WorldFrame and set border heights
				local gwidth, gheight = string.match(GetCVar("gxResolution"),"(%d+).-(%d+)");
				local scale = 768 / gheight;

				if LeaPlusLC["ViewportResize"] == "On" then
					-- Resize is on, remove borders and resize game world
					BordTop:SetHeight(0);
					BordBot:SetHeight(0);
					WorldFrame:SetPoint("TOPLEFT", 0, -(LeaPlusLC["ViewPortTop"] * scale));
					WorldFrame:SetPoint("BOTTOMRIGHT", 0, (LeaPlusLC["ViewPortBottom"] * scale));
				else
					-- Resize is off, set border width and maximise game world
					BordTop:SetHeight(LeaPlusLC["ViewPortTop"]);
					BordBot:SetHeight(LeaPlusLC["ViewPortBottom"]);
					WorldFrame:SetPoint("TOPLEFT", 0, 0);
					WorldFrame:SetPoint("BOTTOMRIGHT", 0, 0);
				end
		
				-- Set left and right border width
				BordLeft:SetWidth(LeaPlusLC["ViewPortLeft"]);
				BordRight:SetWidth(LeaPlusLC["ViewPortRight"]);

				-- Hide the borders if they have no height
				if LeaPlusLC["ViewPortTop"] == 0 then BordTop:Hide(); else BordTop:Show(); end
				if LeaPlusLC["ViewPortBottom"] == 0 then BordBot:Hide(); else BordBot:Show(); end
				if LeaPlusLC["ViewPortLeft"] == 0 then BordLeft:Hide(); else BordLeft:Show(); end
				if LeaPlusLC["ViewPortRight"] == 0 then BordRight:Hide(); else BordRight:Show(); end

				-- Revert to dummy functions to prevent other code from moving WorldFrame
				WorldFrame.ClearAllPoints = WFdummy
				WorldFrame.SetPoint = WFdummy

			end

			-- Create viewport modification side panel
			local SideViewport = LeaPlusLC:CreateSidePanel("Viewport", 164, 340)

			-- Create slider controls
			LeaPlusLC:MakeTx(SideViewport, "Top Border", 10, -60)
			LeaPlusLC:MakeSL(SideViewport, "ViewPortTop", "", 0, 250, 5, 10, -80, "%.0f")
			LeaPlusCB["ViewPortTop"]:HookScript("OnValueChanged", RefreshViewport)

			LeaPlusLC:MakeTx(SideViewport, "Bottom Border", 10, -110)
			LeaPlusLC:MakeSL(SideViewport, "ViewPortBottom", "", 0, 250, 5, 10, -130, "%.0f")
			LeaPlusCB["ViewPortBottom"]:HookScript("OnValueChanged", RefreshViewport)

			LeaPlusLC:MakeTx(SideViewport, "Left Border", 10, -160)
			LeaPlusLC:MakeSL(SideViewport, "ViewPortLeft", "", 0, 250, 5, 10, -180, "%.0f")
			LeaPlusCB["ViewPortLeft"]:HookScript("OnValueChanged", RefreshViewport)

			LeaPlusLC:MakeTx(SideViewport, "Right Border", 10, -210)
			LeaPlusLC:MakeSL(SideViewport, "ViewPortRight", "", 0, 250, 5, 10, -230, "%.0f")
			LeaPlusCB["ViewPortRight"]:HookScript("OnValueChanged", RefreshViewport)

			-- Create resize game world checkbox
			LeaPlusLC:MakeCB(SideViewport, "ViewportResize", "Resize game world", 10, -260, "If checked, the game world will be resized to fit between the top and bottom borders.\n\nThis ensures that none of the game world is blocked by those borders.\n\nNote that this setting has no effect on the left and right borders.", 2)

			-- Create save button
			LeaPlusLC:CreateButton("SaveViewportBtn", SideViewport, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
			LeaPlusCB["SaveViewportBtn"]:SetScript("OnClick", function()
				SideViewport:Hide();
				LeaPlusLC["PageF"]:Show();
				LeaPlusLC["Page7"]:Show();
				return
			end)

			-- Create reset button
			LeaPlusLC:CreateButton("ResetViewportBtn", SideViewport, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
			LeaPlusCB["ResetViewportBtn"]:SetScript("OnClick", function()
				LeaPlusLC["ViewPortTop"] = 0 
				LeaPlusLC["ViewPortBottom"] = 0
				LeaPlusLC["ViewPortLeft"] = 0
				LeaPlusLC["ViewPortRight"] = 0
				LeaPlusLC["ViewportResize"] = "Off"
				SideViewport:Hide(); SideViewport:Show();
				RefreshViewport();
			end)

			-- Handler for options panel ? button
			LeaPlusCB["ModViewportBtn"]:SetScript("OnClick", function()
				if LeaPlusLC:PlayerInCombat() then
					return
				else
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Private profile
						LeaPlusLC["ViewPortTop"] = 5 
						LeaPlusLC["ViewPortBottom"] = 5
						LeaPlusLC["ViewPortLeft"] = 5
						LeaPlusLC["ViewPortRight"] = 5
						LeaPlusLC["ViewportResize"] = "On"
						RefreshViewport();
					else
						SideViewport:Show();
						LeaPlusLC:HideFrames();
					end
				end
			end)

			-- Refresh viewport when resize button is clicked and on startup
			LeaPlusCB["ViewportResize"]:HookScript("OnClick", RefreshViewport)
			RefreshViewport();

			-- Hide the side panel if combat starts (to prevent the dreaded taint)
			SideViewport:RegisterEvent("PLAYER_REGEN_DISABLED")
			SideViewport:SetScript("OnEvent", SideViewport.Hide)

		end

		----------------------------------------------------------------------
		-- Universal group chat color
		----------------------------------------------------------------------

		-- Universal group chat color (ColorPickerFrame:GetColorRGB())
		if LeaPlusDB["UnivGroupColor"] == "On" then -- Checks global
			-- Set raid and instance to party colors
			ChangeChatColor("RAID", 0.67, 0.67, 1)
			ChangeChatColor("RAID_LEADER", 0.46, 0.78, 1)
			ChangeChatColor("INSTANCE_CHAT", 0.67, 0.67, 1)
			ChangeChatColor("INSTANCE_CHAT_LEADER", 0.46, 0.78, 1)
		end

		----------------------------------------------------------------------
		-- No emote sounds while rested
		----------------------------------------------------------------------

		-- No emote sounds while rested (otherwise known as 'Shut up, Dwarf!')
		if LeaPlusDB["ManageRestedEmotes"] == "On" then -- Checks global

			-- Zone table 		English					, French					, German					, Italian						, Russian					, S Chinese	, Spanish					, T Chinese	,
			local zonetable = {	"The Halfhill Market"	, "Marché de Micolline"		, "Der Halbhügelmarkt"		, "Il Mercato di Mezzocolle"	, "Рынок Полугорья"			, "半山市集"	, "El Mercado del Alcor"	, "半丘市集"	,
								"The Grim Guzzler"		, "Le Sinistre écluseur"	, "Zum Grimmigen Säufer"	, "Torvo Beone"					, "Трактир Угрюмый обжора"	, "黑铁酒吧"	, "Tragapenas"				, "黑鐵酒吧"	,
								"The Summer Terrace"	, "La terrasse Estivale"	, "Die Sommerterrasse"		, "Terrazza Estiva"				, "Летняя терраса"			, "夏之台"	, "El Bancal del Verano"	, "夏日露臺"	,
			}

			-- Function to set rested state
			local function UpdateEmoteSound()

				-- Find character's current zone
				local szone = GetSubZoneText() or "None";

				-- Find out if emote sounds are disabled or enabled
				local emoset = GetCVar("Sound_EnableEmoteSounds");

				-- Set emote sound setting
				if LeaPlusLC["NoSoundRested"] == "On" then

					if IsResting() then
						-- Character is resting so silence emotes
						if emoset ~= "0" then
							SetCVar("Sound_EnableEmoteSounds", "0")
						end
						return
					end

					-- Traverse zone table and silence emotes if character is in a designated zone
					for k, v in next, zonetable do
						if szone == zonetable[k] then
							if emoset ~= "0" then
								SetCVar("Sound_EnableEmoteSounds", "0")
							end
							return
						end
					end

				end

				-- If the above didn't return, emote sounds should be enabled
				if emoset ~= "1" then
					SetCVar("Sound_EnableEmoteSounds", "1")
				end
				return
			
			end

			-- Set emote sound when rest state changes
			local RestEvent = CreateFrame("FRAME")
			RestEvent:RegisterEvent("PLAYER_UPDATE_RESTING")
            RestEvent:RegisterEvent("ZONE_CHANGED_NEW_AREA")
			RestEvent:RegisterEvent("ZONE_CHANGED");
			RestEvent:RegisterEvent("ZONE_CHANGED_INDOORS");
            RestEvent:RegisterEvent("SUBZONE_CHANGED_NEW_AREA")
			RestEvent:SetScript("OnEvent", UpdateEmoteSound);

			-- Set sound setting at startup
			UpdateEmoteSound();

			-- Lock emote sounds checkbox in the Blizzard options panel (else it gets confusing)
			AudioOptionsSoundPanelEmoteSounds.Enable = AudioOptionsSoundPanelEmoteSounds.Disable

			-- Update setting when option is clicked
			LeaPlusCB["NoSoundRested"]:HookScript("OnClick", UpdateEmoteSound);

		end

		----------------------------------------------------------------------
		-- Privacy options
		----------------------------------------------------------------------

		-- Privacy options (achievement points)
		if LeaPlusDB["AchieveControl"] == "On" then -- Checks global
			local function DoPrivacy()
				if LeaPlusLC["CharOnlyAchieves"] == "On" then
					ShowAccountAchievements(true);
				else
					ShowAccountAchievements(false);
				end
				InterfaceOptionsPanel_CheckButton_Update(InterfaceOptionsDisplayPanelShowAccountAchievments);
				LeaPlusLC:LockItem(InterfaceOptionsDisplayPanelShowAccountAchievments, true);
			end
			DoPrivacy(); -- Set privacy checkbox on startup if privacy control is enabled
			LeaPlusCB["CharOnlyAchieves"]:HookScript("OnClick", DoPrivacy); -- Set when option is changed
		end

		----------------------------------------------------------------------
		-- Manage camera zoom distance
		----------------------------------------------------------------------

		-- Manage camera zoom distance
		if LeaPlusDB["ManageZoomLevel"] == "On" then -- Checks global

			-- Set the zoom setting on startup
			SetCVar("CameraDistanceMax", "50")
			SetCVar("cameraDistanceMaxFactor", "1")
			InterfaceOptionsCameraPanelMaxDistanceSlider:Disable();

		end

		----------------------------------------------------------------------
		-- Save group roles with spec
		----------------------------------------------------------------------

		-- Save group roles per spec
		if LeaPlusDB["RoleSave"] == "On" then -- Checks global

			-- Create global tables if needed
			LeaPlusDC["RoleSave"] = LeaPlusDC["RoleSave"] or {};
			LeaPlusDC["RoleSave"]["Spec1"] = LeaPlusDC["RoleSave"]["Spec1"] or {};
			LeaPlusDC["RoleSave"]["Spec2"] = LeaPlusDC["RoleSave"]["Spec2"] or {};
			local LFGset = {LEADER, TANK, HEALER, DAMAGER}
			local specsaver = {"primary spec", "secondary spec"}

			-- Print currently selected roles
			local function ShowActiveRoles()
				if LeaPlusLC:IsDualSpec() then
					local newrole = " "
					local newcount = 0
					for k,v in pairs(LFGset) do 
						if select(k, GetLFGRoles()) == true then
							newrole = newrole .. LFGset[k] .. ", "
							newcount = newcount + 1
						end
					end
					if newcount == 1 then
						LeaPlusLC:Print("Your Dungeon Finder role is" .. strsub(newrole, 1, -3) .. ".")
					elseif newcount > 1 then
						LeaPlusLC:Print("Your Dungeon Finder roles are" .. strsub(newrole, 1, -3) .. ".")
					end
				end
			end

			-- Set button state
			local function UpdateSaveRolesButton()
				local CurrentSpec = "Spec" .. GetActiveSpecGroup();
				local LeadRole, TankRole, HealerRole, DamagerRole = GetLFGRoles()
				if LeaPlusDC["RoleSave"][CurrentSpec]["Leader"] == LeadRole and LeaPlusDC["RoleSave"][CurrentSpec]["Tank"] == TankRole and LeaPlusDC["RoleSave"][CurrentSpec]["Healer"] == HealerRole and LeaPlusDC["RoleSave"][CurrentSpec]["Damager"] == DamagerRole then
					LeaPlusCB["SaveLFGRole"]:SetEnabled(false);
				else
					LeaPlusCB["SaveLFGRole"]:SetEnabled(true);
				end
			end

			-- Create button and handler scripts
			LeaPlusLC:CreateButton("SaveLFGRole", GroupFinderFrame, "Save Roles", "BOTTOMLEFT", 60, 10, 100, 25, false, "")
			LeaPlusCB["SaveLFGRole"]:SetScript("OnClick", function()
				-- You click the save button, so save the selected roles
				local CurrentSpec = "Spec" .. GetActiveSpecGroup();
				LeaPlusDC["RoleSave"][CurrentSpec]["Leader"], LeaPlusDC["RoleSave"][CurrentSpec]["Tank"], LeaPlusDC["RoleSave"][CurrentSpec]["Healer"], LeaPlusDC["RoleSave"][CurrentSpec]["Damager"] = GetLFGRoles();
				UpdateSaveRolesButton();
				LeaPlusLC:Print("Your selected roles have been saved to your " .. specsaver[GetActiveSpecGroup()] .. ".")
			end)

			LeaPlusCB["SaveLFGRole"].tiptext = "Click to save your selected group roles to your current talent spec.\n\nYour saved roles will be selected automatically when you switch specs."
			LeaPlusCB["SaveLFGRole"]:SetScript("OnEnter", LeaPlusLC.ShowFacetip)

			LeaPlusCB["SaveLFGRole"]:SetScript("OnShow", function()
				-- Update the save button whenever it's shown
				UpdateSaveRolesButton();
			end)

			LeaPlusCB["SaveLFGRole"]:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
			LeaPlusCB["SaveLFGRole"]:RegisterEvent("LFG_ROLE_UPDATE")
			LeaPlusCB["SaveLFGRole"]:SetScript("OnEvent", function(self,event)
				if event == "LFG_ROLE_UPDATE" then
					-- Your role has changed, update the save button
					UpdateSaveRolesButton();
				elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
					-- Your talent spec has changed, set roles to saved values
					local CurrentSpec = "Spec" .. GetActiveSpecGroup();
					SetLFGRoles(LeaPlusDC["RoleSave"][CurrentSpec]["Leader"],LeaPlusDC["RoleSave"][CurrentSpec]["Tank"],LeaPlusDC["RoleSave"][CurrentSpec]["Healer"],LeaPlusDC["RoleSave"][CurrentSpec]["Damager"])
					ShowActiveRoles();
				end
			end)

			-- Set spec and show information on login
			if LeaPlusLC:IsDualSpec() then
				local CurrentSpec = "Spec" .. GetActiveSpecGroup();
				SetLFGRoles(LeaPlusDC["RoleSave"][CurrentSpec]["Leader"],LeaPlusDC["RoleSave"][CurrentSpec]["Tank"],LeaPlusDC["RoleSave"][CurrentSpec]["Healer"],LeaPlusDC["RoleSave"][CurrentSpec]["Damager"])
				LeaPlusLC:ShowActiveSpec();
				ShowActiveRoles();
			end
		end

		----------------------------------------------------------------------
		-- Blizzard blockers
		----------------------------------------------------------------------

		-- Set trade and guild locks
		if LeaPlusDB["ManageTradeGuild"] == "On" then -- Checks global

			-- Function to check or uncheck trade and guild options in Blizzard options panel
			local function TradeGuild()
				if LeaPlusLC["ManageTradeGuild"] == "On" then
					if LeaPlusLC["NoTradeRequests"] == "On" then
						InterfaceOptionsControlsPanelBlockTrades:SetValue("1");
					else
						InterfaceOptionsControlsPanelBlockTrades:SetValue("0");
					end
					if LeaPlusLC["NoGuildInvites"] == "On" then
						InterfaceOptionsControlsPanelBlockGuildInvites:SetValue("1");
					else
						InterfaceOptionsControlsPanelBlockGuildInvites:SetValue("0");
					end
				end
			end

			-- Set trade and guild checkboxes on startup and lock them to prevent confusion
			TradeGuild();

			InterfaceOptionsControlsPanelBlockTrades:Disable();
			InterfaceOptionsControlsPanelBlockGuildInvites:Disable();
			_G[InterfaceOptionsControlsPanelBlockTrades:GetName() .. 'Text']:SetAlpha(0.6)
			_G[InterfaceOptionsControlsPanelBlockGuildInvites:GetName() .. 'Text']:SetAlpha(0.3)

			-- Set trade and guild checkboxes when options are clicked in Leatrix Plus
			LeaPlusCB["NoTradeRequests"]:HookScript("OnClick", TradeGuild);
			LeaPlusCB["NoGuildInvites"]:HookScript("OnClick", TradeGuild);

		end

		----------------------------------------------------------------------
		-- Use class colors in chat
		----------------------------------------------------------------------

		if LeaPlusDB["Manageclasscolors"] == "On" then -- Checks global

			-- Function to set channel colors
			local function SetChatChannelColor(chatgroup)
				if not chatgroup or chatgroup == "local" then
					-- Set local channel color
					for i=1, 18 do
						if _G["ChatConfigChatSettingsLeftCheckBox" .. i .. "Check"] then
							if LeaPlusLC["ColorLocalChannels"] == "On" then
								ToggleChatColorNamesByClassGroup(true, _G["ChatConfigChatSettingsLeftCheckBox" .. i .. "Check"]:GetParent().type);
							else
								ToggleChatColorNamesByClassGroup(false, _G["ChatConfigChatSettingsLeftCheckBox" .. i .. "Check"]:GetParent().type);
							end
						end
					end
				end
				if not chatgroup or chatgroup == "global" then
					-- Set global channel color
					for i=1, 50 do
						if LeaPlusLC["ColorGlobalChannels"] == "On" then
							ToggleChatColorNamesByClassGroup(true, "CHANNEL"..i)
						else
							ToggleChatColorNamesByClassGroup(false, "CHANNEL"..i)
						end
					end
				end
			end

			-- Set channel colors on startup and when options panel settings are clicked
			SetChatChannelColor()
			LeaPlusCB["ColorLocalChannels"]:HookScript("OnClick", function() SetChatChannelColor("local") end)
			LeaPlusCB["ColorGlobalChannels"]:HookScript("OnClick", function() SetChatChannelColor("global") end)

			-- Lock local channel checkboxes on startup
			for i=1, 18 do
				if _G["ChatConfigChatSettingsLeftCheckBox" .. i .. "Check"] then
					LeaPlusLC:LockItem(_G["ChatConfigChatSettingsLeftCheckBox" .. i .. "ColorClasses"],true)
				end
			end

			-- Lock global channel checkboxes on startup
			hooksecurefunc("ChatConfig_CreateCheckboxes", function(self, checkBoxTable, checkBoxTemplate, title)
				if ChatConfigChannelSettingsLeft.checkBoxTable then
					for i=1,50 do
						if _G["ChatConfigChannelSettingsLeftCheckBox" .. i .. "ColorClasses"] then
							LeaPlusLC:LockItem(_G["ChatConfigChannelSettingsLeftCheckBox" .. i .. "ColorClasses"],true)
						end
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Final code for Player
		----------------------------------------------------------------------

		-- Preload the auction house
		if not IsAddOnLoaded("Blizzard_AuctionUI") then

			-- Preload the auction house to update chat tabs
			UIParentLoadAddOn("Blizzard_AuctionUI");

		end

		-- Unregister the player section (since it should only be run once)
		LpEvt:UnregisterEvent("PLAYER_ENTERING_WORLD")

		-- Release memory
		LeaPlusLC.Player = nil

	end

----------------------------------------------------------------------
-- 	L60: BlizzDep (options which require Blizzard modules)
----------------------------------------------------------------------

	function LeaPlusLC:BlizzDep(module)

		if module == "Blizzard_AuctionUI" then

			----------------------------------------------------------------------
			-- Auction House Extras
			----------------------------------------------------------------------

			-- Auction House buyout only
			if LeaPlusLC["AhExtras"] == "On" then

				-- Set default auction duration value to saved setting or default setting
				AuctionFrameAuctions.duration = LeaPlusDB["AHDuration"] or 3

				-- Change size of maximise buttons to make room for find button
				AuctionsStackSizeMaxButton:SetWidth(50); AuctionsStackSizeMaxButton:SetText("Max")
				AuctionsNumStacksMaxButton:SetWidth(50); AuctionsNumStacksMaxButton:SetText("Max")

				-- Functions
				local function CreateAuctionCB(name, anchor, x, y, text)
					LeaPlusCB[name] = CreateFrame("CheckButton", nil, AuctionFrameAuctions, "OptionsCheckButtonTemplate")
					LeaPlusCB[name]:SetFrameStrata("HIGH")
					LeaPlusCB[name]:SetHitRectInsets(0, 0, 0, 0);
					LeaPlusCB[name]:SetSize(20, 20)
					LeaPlusCB[name]:SetPoint(anchor, x, y)
					LeaPlusCB[name].f = LeaPlusCB[name]:CreateFontString(nil, 'OVERLAY', "GameFontNormal")
					LeaPlusCB[name].f:SetPoint("LEFT", 20, 0)
					LeaPlusCB[name].f:SetText(text)
					LeaPlusCB[name].f:Show();
					LeaPlusCB[name]:SetScript('OnClick', function()
						if LeaPlusCB[name]:GetChecked() == nil then
							LeaPlusLC[name] = "Off"
						elseif LeaPlusCB[name]:GetChecked() == 1 then
							LeaPlusLC[name] = "On"
						end
					end)
					LeaPlusCB[name]:SetScript('OnShow', function(self)
						self:SetChecked(LeaPlusLC[name])
					end)
				end

				-- Show the correct fields in the AH frame and match prices
				local function SetupAh()
					if LeaPlusLC["AhBuyoutOnly"] == "On" then
						-- Hide the start price
						StartPrice:SetAlpha(0);
						-- Set start price to buyout price 
						StartPriceGold:SetText(BuyoutPriceGold:GetText());
						StartPriceSilver:SetText(BuyoutPriceSilver:GetText());
						StartPriceCopper:SetText(BuyoutPriceCopper:GetText());
					else
						-- Show the start price
						StartPrice:SetAlpha(1);
					end
					-- If gold only is on, set copper and silver to 99
					if LeaPlusLC["AhGoldOnly"] == "On" then
						StartPriceCopper:SetText("99"); StartPriceCopper:Disable();
						StartPriceSilver:SetText("99"); StartPriceSilver:Disable();
						BuyoutPriceCopper:SetText("99"); BuyoutPriceCopper:Disable();
						BuyoutPriceSilver:SetText("99"); BuyoutPriceSilver:Disable();
					else
						StartPriceCopper:Enable();
						StartPriceSilver:Enable();
						BuyoutPriceCopper:Enable();
						BuyoutPriceSilver:Enable();
					end
					-- Validate the auction (mainly for the create auction button status)
					AuctionsFrameAuctions_ValidateAuction();
				end

				-- Create checkboxes
				CreateAuctionCB("AhBuyoutOnly", "BOTTOMLEFT", 200, 16, "Buyout Only")
				CreateAuctionCB("AhGoldOnly", "BOTTOMLEFT", 320, 16, "Gold Only")
				
				LeaPlusCB["AhBuyoutOnly"]:HookScript('OnClick', SetupAh);
				LeaPlusCB["AhBuyoutOnly"]:HookScript('OnShow', SetupAh);
	
				AuctionFrameAuctions:HookScript("OnShow", SetupAh)
				BuyoutPriceGold:HookScript("OnTextChanged", SetupAh)
				BuyoutPriceSilver:HookScript("OnTextChanged", SetupAh)
				BuyoutPriceCopper:HookScript("OnTextChanged", SetupAh)
				StartPriceGold:HookScript("OnTextChanged", SetupAh)
				StartPriceSilver:HookScript("OnTextChanged", SetupAh)
				StartPriceCopper:HookScript("OnTextChanged", SetupAh)
	
				-- Lock the create auction button if buyout gold box is empty (when using buyout only and gold only)
				AuctionsCreateAuctionButton:HookScript("OnEnable", function()
					if LeaPlusLC["AhGoldOnly"] == "On" and LeaPlusLC["AhBuyoutOnly"] == "On" then
						if BuyoutPriceGold:GetText() == "" then
							AuctionsCreateAuctionButton:Disable();
						end
					end
				end)
				
				-- Clear copper and silver prices if gold only box is unchecked
				LeaPlusCB["AhGoldOnly"]:HookScript('OnClick', function()
					if LeaPlusCB["AhGoldOnly"]:GetChecked() == nil then
						BuyoutPriceCopper:SetText("")
						BuyoutPriceSilver:SetText("")
						StartPriceCopper:SetText("")
						StartPriceSilver:SetText("")
					end
					SetupAh();
				end)

				-- Create find button
				LeaPlusLC:CreateButton("FindAuctionButton", AuctionFrameAuctions, "Find", "BOTTOMLEFT", 146, 246, 50, 21, false, "")
				LeaPlusCB["FindAuctionButton"]:SetFrameStrata("HIGH")
				LeaPlusCB["FindAuctionButton"]:SetScript("OnClick", function()
					if GetAuctionSellItemInfo() then
						local name = GetAuctionSellItemInfo()
						BrowseName:SetText(name)
						QueryAuctionItems(name)
						AuctionFrameTab1:Click();
					end
				end)

				-- Show find button when required (new item added or window shown)
				local function SetFindButton()
					if GetAuctionSellItemInfo() then 
						LeaPlusCB["FindAuctionButton"]:SetEnabled(true); 
					else 
						LeaPlusCB["FindAuctionButton"]:SetEnabled(false); 
					end; 
				end;

				AuctionFrameAuctions:HookScript("OnShow", function() 
					SetFindButton(); 
				end)

				AuctionsItemButton:HookScript("OnEvent", function(self,event)
					if event == "NEW_AUCTION_UPDATE" then
						SetFindButton(); 
					end
				end)

				-- Hide find button when Blizzard block frame is shown (respecting the Blizzard UI)
				AuctionsBlockFrame:HookScript("OnShow", function() LeaPlusCB["FindAuctionButton"]:Hide(); end)
				AuctionsBlockFrame:HookScript("OnHide", function() LeaPlusCB["FindAuctionButton"]:Show(); end)

				-- Clear the cursor and reset editboxes when a new item replaces an existing one
				hooksecurefunc("AuctionsFrameAuctions_ValidateAuction", function()
					if GetAuctionSellItemInfo() then
						-- Return anything you might be holding
						ClearCursor();
						-- Set copper and silver prices to 99 if gold mode is on
						if LeaPlusLC["AhGoldOnly"] == "On" then
							StartPriceCopper:SetText("99")
							StartPriceSilver:SetText("99")
							BuyoutPriceCopper:SetText("99")
							BuyoutPriceSilver:SetText("99")
						end
					end
				end)
      
				-- Clear gold editbox after an auction has been created (to force user to enter something)
				AuctionsCreateAuctionButton:HookScript("OnClick", function()
					StartPriceGold:SetText("")
					BuyoutPriceGold:SetText("")
				end)

				-- Set tab key actions (if different from Blizzard defaults)
				StartPriceGold:HookScript("OnTabPressed", function()
					if not IsShiftKeyDown() then
						if LeaPlusLC["AhBuyoutOnly"] == "Off" and LeaPlusLC["AhGoldOnly"] == "On" then
							BuyoutPriceGold:SetFocus()
						end
					end
				end)

				BuyoutPriceGold:HookScript("OnTabPressed", function()
					if IsShiftKeyDown() then
						if LeaPlusLC["AhBuyoutOnly"] == "Off" and LeaPlusLC["AhGoldOnly"] == "On" then
							StartPriceGold:SetFocus()
						end
					end
				end)

			end
	
		elseif module == "Blizzard_ItemAlterationUI" then

			-- Hide character controls (transmogrification window)
			if LeaPlusLC["NoCharControls"] == "On" then
				TransmogrifyModelFrameControlFrame:HookScript("OnShow", TransmogrifyModelFrameControlFrame.Hide)
			end

		end

	end
	
----------------------------------------------------------------------
-- 	L62: RunOnce
----------------------------------------------------------------------

	function LeaPlusLC:RunOnce()

		-- Disable Blizzard's UI settings sync process (to avoid unwanted changes)
		SetCVar("synchronizeConfig", "0")

		-- Fix the quest fading bug (may as well disable it here as there's no option to use it in the client)
		QuestInfoDescriptionText.SetAlphaGradient = function() return end

		-- Hide Leatrix Plus if Blizzard options are shown (else it gets confusing)
		InterfaceOptionsFrame:HookScript("OnShow", LeaPlusLC.HideFrames);
		VideoOptionsFrame:HookScript("OnShow", LeaPlusLC.HideFrames);

		-- Create secure button to enable a macro to be used to stop targeting a spell
		local LeaPlusClearSpell = CreateFrame("Button", "LeaPlusClearSpell", UIParent, "SecureActionButtonTemplate")
		LeaPlusClearSpell:SetAttribute("type", "stop")

		----------------------------------------------------------------------
		-- Invite from whisper configuration panel
		----------------------------------------------------------------------

		-- Create configuration panel
		local InvPanel = LeaPlusLC:CreateSidePanel("Invite Whispers", 164, 170)

		-- Add editbox
		LeaPlusLC:MakeTx(InvPanel, "Keyword", 10, -60)
		local KeyBox = LeaPlusLC:CreateEditBox("KeyBox", InvPanel, 140, 10, "TOPLEFT", 14, -80, "KeyBox", "KeyBox");

		-- Save the keyword
		local function SetInvKey()
			LeaPlusLC["InvKey"] = KeyBox:GetText() or "plus"
		end

		-- Create save button
		LeaPlusLC:CreateButton("SaveInvBtn", InvPanel, "Save", "BOTTOMLEFT", 10, 10, 70, 25, true, "")
		LeaPlusCB["SaveInvBtn"]:ClearAllPoints()
		LeaPlusCB["SaveInvBtn"]:SetPoint("BOTTOMLEFT", 10, 10)
		LeaPlusCB["SaveInvBtn"]:SetScript("OnClick", function()
			-- Set keyword to default if keyword box is empty
			if KeyBox:GetText() == "" then KeyBox:SetText("plus") end
			-- Save the keyword
			SetInvKey()
			-- Show the options panel
			InvPanel:Hide(); LeaPlusLC["PageF"]:Show(); LeaPlusLC["Page1"]:Show();
			return
		end)

		-- Create reset button
		LeaPlusLC:CreateButton("ResetInvBtn", InvPanel, "Reset", "BOTTOMLEFT", 80, 10, 70, 25, true, "")
		LeaPlusCB["ResetInvBtn"]:ClearAllPoints()
		LeaPlusCB["ResetInvBtn"]:SetPoint("BOTTOMRIGHT", -10, 10)
		LeaPlusCB["ResetInvBtn"]:SetScript("OnClick", function()
			-- Reset the keyword to default
			LeaPlusLC["InvKey"] = "plus"
			-- Set the editbox to default
			KeyBox:SetText("plus")
			-- Save the keyword
			SetInvKey();
			-- Refresh panel
			InvPanel:Hide(); InvPanel:Show();
		end)

		-- Ensure keyword is a string on startup
		LeaPlusLC["InvKey"] = tostring(LeaPlusLC["InvKey"]) or ""

		-- Set editbox value when shown
		KeyBox:HookScript("OnShow", function()
			KeyBox:SetText(LeaPlusLC["InvKey"])
		end)

		-- Show the panel when options panel button is clicked
		LeaPlusCB["InvWhisperBtn"]:SetScript("OnClick", function()
			if IsShiftKeyDown() and IsControlKeyDown() then
				-- Private profile
				LeaPlusLC["InvKey"] = "plus"
				KeyBox:SetText(LeaPlusLC["InvKey"]);
				SetInvKey();
			else
				-- Show panel
				InvPanel:Show()
				LeaPlusLC:HideFrames();
			end
		end)

		-- Show option tooltip with keyword highlighted
		LeaPlusCB["InviteFromWhisper"]:HookScript("OnEnter", function(self)
			self.tiptext = "If checked, when someone whispers a keyword to you, they will be automatically invited to a group with you.\n\nYou need to be either ungrouped or party leader in your own group for this to work.\n\nYou can change the keyword by clicking the configuration button to the right.\n\nKeyword: |cffffffff" .. LeaPlusLC["InvKey"]
			GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
		end)

		----------------------------------------------------------------------
		-- Options panel scale
		----------------------------------------------------------------------

		-- Leatrix Plus options panel scale
		local function SetPlusScale()
			-- Set panel scale
			if LeaPlusLC["PlusPanelScaleCheck"] == "On" then
				LeaPlusLC["PageF"]:SetScale(LeaPlusLC["LeaPlusScaleValue"])
			else
				LeaPlusLC["PageF"]:SetScale(1.00)
			end
		end

		-- Set scale on startup
		SetPlusScale();

		-- Set scale after changing slider or checkbox
		LeaPlusCB["LeaPlusScaleValue"]:HookScript("OnMouseUp", SetPlusScale);
		LeaPlusCB["LeaPlusScaleValue"]:HookScript("OnMouseWheel", SetPlusScale);
		LeaPlusCB["PlusPanelScaleCheck"]:HookScript("OnClick", SetPlusScale);

		----------------------------------------------------------------------
		-- Options panel alpha
		----------------------------------------------------------------------

		-- Leatrix Plus options panel alpha
		local function SetPlusAlpha()
			if LeaPlusLC["PlusPanelAlphaCheck"] == "On" then
				LeaPlusLC["PageF"].t:SetAlpha(LeaPlusLC["LeaPlusAlphaValue"])
			else
				LeaPlusLC["PageF"].t:SetAlpha(1.0)
			end
		end

		-- Set alpha on startup
		SetPlusAlpha();

		-- Set alpha after changing slider or checkbox
		LeaPlusCB["LeaPlusAlphaValue"]:HookScript("OnValueChanged", SetPlusAlpha);
		LeaPlusCB["PlusPanelAlphaCheck"]:HookScript("OnClick", SetPlusAlpha);

		----------------------------------------------------------------------
		-- Final code for RunOnce
		----------------------------------------------------------------------

		-- Update addon memory usage (speeds up initial value)
		UpdateAddOnMemoryUsage();

		-- Release memory
		LeaPlusLC.RunOnce = nil

	end

----------------------------------------------------------------------
-- 	L64: Default Events
----------------------------------------------------------------------

	local function eventHandler(self, event, arg1, arg2, ...)

		----------------------------------------------------------------------
		-- Invite from whisper
		----------------------------------------------------------------------

		if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER" then
			if (not UnitExists("party1") or UnitIsGroupLeader("player")) and strlower(arg1) == strlower(LeaPlusLC["InvKey"]) then
				if not LeaPlusLC:IsInLFGQueue() then
					if event == "CHAT_MSG_WHISPER" then
						InviteUnit(arg2)
					elseif event == "CHAT_MSG_BN_WHISPER" then
						local void, toonname, void, realmname = BNGetToonInfo(select(11, ...))
						InviteUnit(toonname .. "-" .. realmname)
					end
				end
			end
			return
		end

		----------------------------------------------------------------------
		-- Block duel requests
		----------------------------------------------------------------------

		if event == "DUEL_REQUESTED" and not LeaPlusLC:RealIDCheck(arg1) and not LeaPlusLC:FriendCheck(arg1) then
			CancelDuel();
			StaticPopup_Hide("DUEL_REQUESTED");
			return
		end

		----------------------------------------------------------------------
		-- Block pet battle duel requests
		----------------------------------------------------------------------

		if event == "PET_BATTLE_PVP_DUEL_REQUESTED" and not LeaPlusLC:RealIDCheck(arg1) and not LeaPlusLC:FriendCheck(arg1) then
			C_PetBattles.CancelPVPDuel()
			return
		end

		----------------------------------------------------------------------
		-- Automatically accept resurrection requests
		----------------------------------------------------------------------

		if event == "RESURRECT_REQUEST" then
			if GetCorpseRecoveryDelay() == 0 then
				if ((UnitAffectingCombat(arg1)) and LeaPlusLC["NoAutoResInCombat"] == "Off") or not (UnitAffectingCombat(arg1)) then
					AcceptResurrect()
					StaticPopup_Hide("RESURRECT_NO_TIMER")
					DoEmote("thank", arg1)
				end
			end
			return
		end

		----------------------------------------------------------------------
		-- Automatically accept summon requests
		----------------------------------------------------------------------

		if event == "CONFIRM_SUMMON" then
			if not UnitAffectingCombat("player") then
				ConfirmSummon()
				StaticPopup_Hide("CONFIRM_SUMMON")
			end
			return
		end

		----------------------------------------------------------------------
		-- Block party invites
		----------------------------------------------------------------------

		if event == "PARTY_INVITE_REQUEST" then

			-- If a friend, accept if you're accepting friends and not in Dungeon Finder
			if 	(LeaPlusLC["AcceptPartyFriends"] == "On" and LeaPlusLC:FriendCheck(arg1)) or
				(LeaPlusLC["AcceptPartyFriends"] == "On" and LeaPlusLC:RealIDCheck(arg1)) then

				if not LeaPlusLC:IsInLFGQueue() then
					AcceptGroup();
					for i=1, STATICPOPUP_NUMDIALOGS do
						if _G["StaticPopup"..i].which == "PARTY_INVITE" then
							_G["StaticPopup"..i].inviteAccepted = 1
							StaticPopup_Hide("PARTY_INVITE");
							break
						elseif _G["StaticPopup"..i].which == "PARTY_INVITE_XREALM" then
							_G["StaticPopup"..i].inviteAccepted = 1
							StaticPopup_Hide("PARTY_INVITE_XREALM");
							break
						end
					end
					return
				end

			end

			-- If not a friend and you're blocking invites, decline
			if LeaPlusLC["NoPartyInvites"] == "On" then
				if LeaPlusLC:FriendCheck(arg1) or LeaPlusLC:RealIDCheck(arg1) then
					return
				else
					DeclineGroup();
					StaticPopup_Hide("PARTY_INVITE");
					StaticPopup_Hide("PARTY_INVITE_XREALM");
					return
				end
			end

			return
		end

		----------------------------------------------------------------------
		-- Hide loot warnings
		----------------------------------------------------------------------

		if event == "CONFIRM_LOOT_ROLL" or event == "CONFIRM_DISENCHANT_ROLL" then
			ConfirmLootRoll(arg1, arg2)
			StaticPopup_Hide("CONFIRM_LOOT_ROLL")
			return
		end

		if event == "LOOT_BIND_CONFIRM" then
			ConfirmLootSlot(arg1, arg2)
			StaticPopup_Hide("LOOT_BIND",...)
			return
		end

		----------------------------------------------------------------------
		-- Automatically accept quests
		----------------------------------------------------------------------

		-- Automatically accept all quests or daily quests with daily check on
		if event == "QUEST_DETAIL" then
			if ((LeaPlusLC["AutoAcceptQuests"] == "On" and LeaPlusLC["AcceptOnlyDailys"] == "Off") or (LeaPlusLC["AutoAcceptQuests"] == "On" and LeaPlusLC["AcceptOnlyDailys"] == "On" and QuestIsDaily() == 1)) then
				if not IsShiftKeyDown() then
					if not QuestGetAutoAccept() then
						-- If quest requires an accept click
						AcceptQuest()
					else
						-- If it's automatically accepted, just close the window
						CloseQuest()
					end
				end
			end
			return
		end

		-- Quests requiring confirmation
		if event == "QUEST_ACCEPT_CONFIRM" then
			if ((LeaPlusLC["AutoAcceptQuests"] == "On" and LeaPlusLC["AcceptOnlyDailys"] == "Off") or (LeaPlusLC["AutoAcceptQuests"] == "On" and LeaPlusLC["AcceptOnlyDailys"] == "On" and QuestIsDaily() == 1)) then
				if not IsShiftKeyDown() then
					ConfirmAcceptQuest()
					StaticPopup_Hide("QUEST_ACCEPT_CONFIRM")
				end
			end
			return
		end

		----------------------------------------------------------------------
		-- Automatically turn-in quests
		----------------------------------------------------------------------

		-- Active quest turn-ins
		if event == "QUEST_PROGRESS" then
			if ((LeaPlusLC["AutoTurnInQuests"] == "On" and LeaPlusLC["TurnInOnlyDailys"] == "Off") or (LeaPlusLC["AutoTurnInQuests"] == "On" and LeaPlusLC["TurnInOnlyDailys"] == "On" and QuestIsDaily() == 1)) then
				if not IsShiftKeyDown() then
					if IsQuestCompletable() then
						CompleteQuest()
					end
				end
			end
			return
		end

		-- Turn-in completed quest
		if event == "QUEST_COMPLETE" then
			if ((LeaPlusLC["AutoTurnInQuests"] == "On" and LeaPlusLC["TurnInOnlyDailys"] == "Off") or (LeaPlusLC["AutoTurnInQuests"] == "On" and LeaPlusLC["TurnInOnlyDailys"] == "On" and QuestIsDaily() == 1)) then
				if not IsShiftKeyDown() then
					if GetNumQuestChoices() <= 1 then
						-- If there is only one reward item offered, grab it
						GetQuestReward(GetNumQuestChoices())
					end
				end
			end
			return
		end

		----------------------------------------------------------------------
		-- Automatically release in battlegrounds
		----------------------------------------------------------------------

		if event == "PLAYER_DEAD" then
			local InstStat, InstType = IsInInstance();
			if InstStat == 1 and InstType == "pvp" then
				-- Check for soulstone
				if not (HasSoulstone()) then
					RepopMe();
				end
			end
			return
		end

		----------------------------------------------------------------------
		-- Sell junk and automatically repair
		----------------------------------------------------------------------

		if event == "MERCHANT_SHOW" then

			----------------------------------------------------------------------
			-- Automatically sell junk
			----------------------------------------------------------------------

			if LeaPlusLC["AutoSellJunk"] == "On" then

				local Total = 0
				local SoldCount = 0
				local Rarity = 0
				local ItemPrice = 0
				local ItemCount = 0
				local CurrentItemLink

				for BagID = 0,4 do
					for BagSlot = 1, GetContainerNumSlots(BagID) do
						CurrentItemLink = GetContainerItemLink(BagID, BagSlot)
						if CurrentItemLink then
							void, void, Rarity, void, void, void, void, void, void, void, ItemPrice = GetItemInfo(CurrentItemLink)
							void, ItemCount = GetContainerItemInfo(BagID, BagSlot)
							if Rarity == 0 and ItemPrice ~= 0 then
								Total = Total + (ItemPrice * ItemCount)
								SoldCount = SoldCount + 1
								UseContainerItem(BagID, BagSlot)
							end
						end
					end
				end
				if Total ~= 0 then
					if SoldCount == 1 then
						LeaPlusLC:Print("Sold " .. SoldCount .. " item for " .. GetCoinText(Total) .. ".")
					else
						LeaPlusLC:Print("Sold " .. SoldCount .. " items for " .. GetCoinText(Total) .. ".")
					end
				end
			end

			----------------------------------------------------------------------
			-- Automatically repair
			----------------------------------------------------------------------

			if LeaPlusLC["AutoRepairOwnFunds"] == "On" then

				if CanMerchantRepair() then
					local PlayerMoney = GetMoney()
					local RepairCost, CanRepair = GetRepairAllCost()

					local function RepairOwnFunds()
						-- Guild repair option is off or player isn't guilded
						if PlayerMoney == nil then PlayerMoney = 0 end
						if (RepairCost <= PlayerMoney) then
							RepairAllItems()
							LeaPlusLC:Print("Repaired for " .. GetCoinText(RepairCost) .. ".")
						else
							LeaPlusLC:Print("The repair cost is " .. GetCoinText(RepairCost) ..".  You do not have enough money.")
						end
					end

					local function RepairGuildFunds()
						-- Guild repair
						RepairAllItems(1)
						LeaPlusLC:Print("Repaired for " .. GetCoinText(RepairCost) .. " (guild).")
					end

					if (CanRepair) then -- if the repair option is available at the merchant

						-- Guild repair first (eek!) if guild option is on and player is in guild
						if LeaPlusLC["AutoRepairGuildFunds"] == "On" and IsInGuild() then
							if CanGuildBankRepair() then -- If you have permission to use guilf funds
								local withdrawLimit = GetGuildBankWithdrawMoney()
								local guildBankMoney = GetGuildBankMoney()
								if guildBankMoney == 0 then 
									-- Guild funds not cached due to Blizzards bugged API
									LeaPlusLC:Print("Repaired for " .. GetCoinText(RepairCost) .." (blind).")
									RepairAllItems(1)
									RepairAllItems()
									return
								else
									-- Unlimited funds (guild leader)
									if (withdrawLimit == -1) then withdrawLimit = guildBankMoney else withdrawLimit = min(withdrawLimit, guildBankMoney) end
									if (RepairCost <= withdrawLimit) then
										-- Character is guilded, has permission to guild repair and has guild funds
										RepairGuildFunds();
									else
										-- Character is guilded, has permission to repair but not enough guild funds
										RepairOwnFunds();
									end
								end
							else
								-- Character is guilded but cannot use guild funds so use personal funds
								RepairOwnFunds();
							end
						else
							-- Character is unguilded or guild repair option is disabled
							RepairOwnFunds();
						end
					end
				end
			end
			return

		end

		----------------------------------------------------------------------
		-- Leatrix Plus system events
		----------------------------------------------------------------------

		if event == "ADDON_LOADED" then

			if arg1 == "Leatrix_Plus" then
				LeaPlusLC:Load(); -- Load global settings
				LeaPlusLC:Live(); -- Run code from the live environment
				LeaPlusLC:Isolated(); -- Run code inside the isolated environment
				LeaPlusLC:RunOnce(); -- Run code designed to be run once with no qualifying options
				LeaPlusLC:SetDim(); -- Lock invalid options
			elseif arg1 == "Blizzard_AuctionUI" or arg1 == "Blizzard_ItemAlterationUI" then
				LeaPlusLC:BlizzDep(arg1); -- Load code which requires Blizzard addons
			end

			return
		end

		if event == "VARIABLES_LOADED" then
			LeaPlusLC:Variable()
			if LeaPlusLC["ShowStartTag"] == "On" then
				LeaPlusLC:Print("Leatrix Plus " .. LeaPlusLC["AddonVer"] .. ".");
			end
			return
		end

		if event == "PLAYER_ENTERING_WORLD" then
			LeaPlusLC:Player();
			-- Force the camera zoom to refresh
			CameraZoomOut(0);
			collectgarbage()
			return
		end

		-- Save locals back to globals on logout
		if event == "PLAYER_LOGOUT" then

			-- Run the logout function without wipe flag
			LeaPlusLC:PlayerLogout(false)

			-- Save global options
			LeaPlusLC:Save();

			return
		end

	end

--	Register event handler
	LpEvt:SetScript("OnEvent", eventHandler);

----------------------------------------------------------------------
--	L66: Player Logout
----------------------------------------------------------------------

	-- Player Logout
	function LeaPlusLC:PlayerLogout(wipe)

		----------------------------------------------------------------------
		-- Restore default values if options were unchecked or wiped
		----------------------------------------------------------------------

		-- Manage privacy
		if LeaPlusDB["AchieveControl"] == "On" then
			if wipe or (not wipe and LeaPlusLC["AchieveControl"] == "Off") then
				ShowAccountAchievements(false);
			end
		end

		-- Manage class colors
		if LeaPlusDB["Manageclasscolors"] == "On" then
			if wipe or (not wipe and LeaPlusLC["Manageclasscolors"] == "Off") then
				-- Restore local channel color
				for i = 1, 18 do
					if _G["ChatConfigChatSettingsLeftCheckBox" .. i .. "Check"] then
						ToggleChatColorNamesByClassGroup(false, _G["ChatConfigChatSettingsLeftCheckBox" .. i .. "Check"]:GetParent().type);
					end
				end
				-- Restore global channel color
				for i = 1, 50 do
					ToggleChatColorNamesByClassGroup(false, "CHANNEL"..i)
				end
			end
		end

		-- Manage Blizzard blockers
		if LeaPlusDB["ManageTradeGuild"] == "On" then
			if wipe or (not wipe and LeaPlusLC["ManageTradeGuild"] == "Off") then
				InterfaceOptionsControlsPanelBlockTrades:SetValue("0")
				InterfaceOptionsControlsPanelBlockGuildInvites:SetValue("0")
			end
		end

		-- Map customisation
		if LeaPlusDB["ShowMapMod"] == "On" then
			if wipe or (not wipe and LeaPlusLC["ShowMapMod"] == "Off") then
				SetCVar("worldMapOpacity", "0")
				SetCVar("lockedWorldMap", "1")
			end
		end

		-- Show volume control
		if LeaPlusDB["ShowVolume"] == "On" then
			if wipe or (not wipe and LeaPlusLC["ShowVolume"] == "Off") then
				SetCVar("Sound_MasterVolume", "1")
			end
		end

		-- Hide chat buttons
		if LeaPlusDB["NoChatButtons"] == "On" then
			if wipe or (not wipe and LeaPlusLC["NoChatButtons"] == "Off") then
				SetCVar("chatMouseScroll", "0")
			end
		end

		-- Manage Battle.net friend requests
		if LeaPlusDB["ManageBnetReq"] == "On" then
			if wipe or (not wipe and LeaPlusLC["ManageBnetReq"] == "Off") then
				SetCVar("showToastFriendRequest", "1")
			end
		end

		-- Manage emote sounds
		if LeaPlusDB["ManageRestedEmotes"] == "On" then
			if wipe or (not wipe and LeaPlusLC["ManageRestedEmotes"] == "Off") then
				SetCVar("Sound_EnableEmoteSounds", "1")
			end
		end

		-- Manage zoom level
		if LeaPlusDB["ManageZoomLevel"] == "On" then
			if wipe or (not wipe and LeaPlusLC["ManageZoomLevel"] == "Off") then
				SetCVar("CameraDistanceMax", "15")
				SetCVar("cameraDistanceMaxFactor", "1")
			end
		end

		-- Universal group color
		if LeaPlusDB["UnivGroupColor"] == "On" then
			if wipe or (not wipe and LeaPlusLC["UnivGroupColor"] == "Off") then
				ChangeChatColor("RAID", 1, 0.50, 0)
				ChangeChatColor("RAID_LEADER", 1, 0.28, 0.04)
				ChangeChatColor("INSTANCE_CHAT", 1, 0.50, 0)
				ChangeChatColor("INSTANCE_CHAT_LEADER", 1, 0.28, 0.04)
			end
		end

		----------------------------------------------------------------------
		-- Do other stuff during logout
		----------------------------------------------------------------------

		-- Prevent Blizzard from caching frames if frame customisation is enabled
		if LeaPlusDB["FrmEnabled"] == "On" then
			PlayerFrame:SetUserPlaced(false)
			TargetFrame:SetUserPlaced(false)
		end

		-- Store the auction house duration value if auction house option is enabled
		if LeaPlusDB["AhExtras"] == "On" then
			if AuctionFrameAuctions and AuctionFrameAuctions.duration then
				LeaPlusDB["AHDuration"] = AuctionFrameAuctions.duration
			end
		end

	end

----------------------------------------------------------------------
--	L70: Slash commands
----------------------------------------------------------------------

--	Slash command handler
	function LeaPlusLC:Slash(str)

		local helpmsg

		-- Split command from argument
		local com = gsub(str, "%s*;*([%w]+).*", "%1");
		local arg = gsub(str, "%s*;*([%w]+)%s*(.*)", "%2");

		-- Parse command string
		if com == "" then
			-- Prevent toggling options panel if version panel or Blizzard options panel is showing (else it gets confusing)
			if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then return end
			if LeaPlusLC["VersionPanel"] and LeaPlusLC["VersionPanel"]:IsShown() then return end
			-- Toggle the options panel
			if LeaPlusLC["PageF"]:IsShown() then
				LeaPlusLC:HideFrames();
			else
				LeaPlusLC:HideFrames();
				LeaPlusLC["PageF"]:Show();
			end
			-- Show the correct menu
			if LeaPlusLC["OpenPlusAtHome"] == "Off" then
				-- If previously viewed page is stored and show home on startup is disabled, show last viewed page
				LeaPlusLC["Page" .. LeaPlusLC["LeaStartPage"]]:Show()
			else
				-- Otherwise, show the home page
				LeaPlusLC["Page0"]:Show();
			end
			return

		-- Show help
		elseif com == "help" then 
			-- Show help
			helpmsg = "Leatrix Plus\n/ltp - Toggle the options panel"
			helpmsg = helpmsg .. "\n/ltp char - Show character commands"
			helpmsg = helpmsg .. "\n/ltp reset - Show reset commands"
			helpmsg = helpmsg .. "\n/ltp addon - Show addon commands"
			helpmsg = helpmsg .. "\n/ltp debug - Show debug commands"
			LeaPlusLC:Print(helpmsg)
			return

		-- Debug commands
		elseif com == "debug" then
			-- Combat log
			if arg == "log" then
				LeaPlusLC:Print("DEBUG: Combat Log\n")
				if ChatFrame2.isDocked then
					LeaPlusLC:Print("Dock status: |cffffffffDocked")
				else
					LeaPlusLC:Print("Dock status: |cffffffffUndocked")
				end
				LeaPlusLC:Print("|r")
				LeaPlusLC:Print("Frame parent: |cffffffff" .. tostring(ChatFrame2:GetParent():GetName()) or "None")
				LeaPlusLC:Print("Frame script: |cffffffff" .. tostring(ChatFrame2:GetScript("OnUpdate")) or "None")
				LeaPlusLC:Print("|r")
				LeaPlusLC:Print("Tab parent: |cffffffff" .. tostring(ChatFrame2Tab:GetParent():GetName()) or "None")
				LeaPlusLC:Print("Tab script: |cffffffff" .. tostring(ChatFrame2Tab:GetScript("OnUpdate")) or "None")
				return
			elseif arg == "frame" then
				-- Load debug tools
				if not (IsAddOnLoaded("Blizzard_DebugTools")) then
					UIParentLoadAddOn("Blizzard_DebugTools")
				end
				-- Show the framestack
				FrameStackTooltip_Toggle();
				return
			else
				-- Show debug help
				helpmsg = "Debug commands"
				helpmsg = helpmsg .. "\n/ltp debug frame - Show frame data"
				helpmsg = helpmsg .. "\n/ltp debug log - Show combat log data"
				LeaPlusLC:Print(helpmsg)
				return
			end
			return

		-- Toggle frame information window (undocumented)
		elseif com == "f" then
			-- Load debug tools
			if not (IsAddOnLoaded("Blizzard_DebugTools")) then
				UIParentLoadAddOn("Blizzard_DebugTools")
			end
			-- Show the framestack
			FrameStackTooltip_Toggle();
			return

		-- Character commands
		elseif com == "char" then
			if arg == "exit" then
				-- Exit vehicle
				VehicleExit()
				return
			elseif arg == "hk" then
				local ltphk = GetStatistic(588)
				if ltphk == "--" then ltphk = "no" end
				LeaPlusLC:Print("You have " .. ltphk .. " lifetime honorable kills.")
			elseif arg == "rest" then
				-- Show rested bubbles
				local XPMax = UnitXPMax("player");
				local PlayerXP = UnitXP("player");
				local RestedXP = GetXPExhaustion();
				if not RestedXP then
					LeaPlusLC:Print("You have no rested bubbles.");
				else 
					LeaPlusLC:Print("You have " .. (math.floor(20 * RestedXP / XPMax + 0.5)) .. " rested bubbles.");
				end
				return
			else
				-- Show help message
				helpmsg = "Character commands:\n/ltp char exit - Exit vehicle\n/ltp char hk - Show lifetime HKs\n/ltp char rest - Show rested bubbles"
				LeaPlusLC:Print(helpmsg)
				return
			end
			return

		-- Addon commands
		elseif com == "addon" then
			-- Toggle addon state
			if arg == "" then
				-- No addon argument so just show help message
				helpmsg = "Addon commands:"
				helpmsg = helpmsg .. "\n/ltp addon <addon name> - Toggle addon enabled state (reloads UI).  The addon name will be the same as the addon folder name."
				LeaPlusLC:Print(helpmsg)
				return
			elseif arg == "zygor" then
				-- Toggle Zygor addon
				LeaPlusLC:ZygorToggle();
				return
			elseif select(2, GetAddOnInfo(arg)) then
				-- Addon exists so toggle state and reload UI
				if not IsAddOnLoaded(arg) then
					EnableAddOn(arg)
				else
					DisableAddOn(arg)
				end
				ReloadUI()
			else
				-- Addon not found
				LeaPlusLC:Print("Addon '" .. arg .. "' cannot be found.")
			end
			return

		-- Reset commands
		elseif com == "reset" then
			if arg == "panel" then
				-- Reset the panel position
				LeaPlusLC["MainPanelA"], LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"] = "CENTER", "CENTER", 0, 0
				if LeaPlusLC["PageF"]:IsShown() then 
					LeaPlusLC["PageF"]:Hide()
					LeaPlusLC["PageF"]:Show()
				end
				LeaPlusLC:Print("Panel position has been reset.")
				return
			elseif arg == "gfx" then
				-- Reset the graphics subsystem
				RestartGx();
				return
			elseif arg == "wipe" then
				-- Run the logout function first with wipe flag set
				LeaPlusLC:PlayerLogout(true)
				-- Wipe the global tables
				wipe(LeaPlusDB)
				wipe(LeaPlusDC)
				-- Prevent PLAYER_LOGOUT from saving settings
				LpEvt:UnregisterAllEvents();
				-- Reload the UI
				ReloadUI();
				return
			else
				helpmsg = "Reset commands:\n/ltp reset panel - Reset panel position"
				helpmsg = helpmsg .. "\n/ltp reset gfx - Reset graphics subsystem"
				helpmsg = helpmsg .. "\n/ltp reset wipe - Wipe ALL settings"
				LeaPlusLC:Print(helpmsg)
				return
			end
			return
		else
			-- User entered unknown command
			LeaPlusLC:Print("Invalid command.  Type '/ltp help' for help.")
			return
		end

	end

--	Slash command support
	SLASH_LEATRIX_PLUS_LTP1 = '/ltp'
	SLASH_LEATRIX_PLUS_LTP2 = '/leaplus'

	SlashCmdList["LEATRIX_PLUS_LTP"] = function(str)
		LeaPlusLC:Slash(string.lower(str));
	end

	SLASH_LEATRIX_PLUS_RL1 = '/rl'
	SlashCmdList["LEATRIX_PLUS_RL"] = function(str)
		ReloadUI();
	end
	
----------------------------------------------------------------------
-- 	L75: Options panel functions
----------------------------------------------------------------------

	-- Create a side panel (used for additional configuration)
	function LeaPlusLC:CreateSidePanel(title, width, height)

		-- Create side panel
		local Side = CreateFrame("Frame")
		Side:Hide(); Side:SetSize(width, height); Side:SetToplevel(true)
		Side:ClearAllPoints(); Side:SetPoint("RIGHT", 0, 0)
		Side:SetClampedToScreen(true); Side:EnableMouse(true); Side:SetFrameStrata("FULLSCREEN_DIALOG")

		-- Add background color
		Side.t = Side:CreateTexture(nil, "BACKGROUND")
		Side.t:SetAllPoints()
		Side.t:SetTexture(0.05, 0.05, 0.05, 0.9)

		-- Create draggable title region
		local tBox = Side:CreateTitleRegion()
		tBox:SetPoint("TOPLEFT", 0, 0)
		tBox:SetPoint("TOPRIGHT", 0, 0)
		tBox:SetHeight(50)

		-- Set alpha to match main panel
		Side:HookScript("OnShow", function()
			if LeaPlusLC["PlusPanelAlphaCheck"] == "On" then
				Side.t:SetAlpha(LeaPlusLC["LeaPlusAlphaValue"])
			else
				Side.t:SetAlpha(1.00)
			end
		end)

		-- Add textures
		local function CreateBar(name, parent, width, height, anchor, r, g, b, alp, tex)
			local ft = parent:CreateTexture(nil, "BORDER")
			ft:SetTexture(tex)
			ft:SetSize(width, height)  
			ft:SetPoint(anchor)
			ft:SetVertexColor(r ,g, b, alp)
			if name == "MainTexture" then
				ft:SetTexCoord(0.09, 1, 0, 1);
			end
		end

		CreateBar("MainTexture", Side, width, height - 42, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		CreateBar("FootTexture", Side, width, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

		-- Add title
		Side.f = Side:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		Side.f:SetPoint('TOPLEFT', 10, -10);
		Side.f:SetText(title)

		-- Add description
		LeaPlusLC:MakeWD(Side, "Configuration Panel", 10, -30)
	
		-- Prevent options panel from showing while side panel is showing
		LeaPlusLC["PageF"]:HookScript("OnShow", function()
			if Side:IsShown() then LeaPlusLC["PageF"]:Hide(); end
		end)

		-- Return the frame
		return Side

	end

	-- Define subheadings
	function LeaPlusLC:MakeTx(frame, title, x, y)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		text:SetPoint("TOPLEFT", x, y)
		text:SetText(title)
	end

	-- Define text
	function LeaPlusLC:MakeWD(frame, title, x, y)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		text:SetPoint("TOPLEFT", x, y)
		text:SetText(title)
		text:SetJustifyH"LEFT";
	end

	-- Create a slider control (uses standard template)
	function LeaPlusLC:MakeSL(frame, field, caption, low, high, step, x, y, form)

		-- Create slider control
		local Slider = CreateFrame("Slider", "LeaPlusGlobalSlider" .. field, frame, "OptionssliderTemplate")
		LeaPlusCB[field] = Slider;
		Slider:SetMinMaxValues(low, high)
		Slider:SetValueStep(step)
		Slider:EnableMouseWheel(true)
		Slider:SetPoint('TOPLEFT', x,y)
		Slider:SetWidth(100)
		Slider:SetHeight(20)
		Slider:SetHitRectInsets(0, 0, 0, 0);

		-- Remove slider text
		_G[Slider:GetName().."Low"]:SetText('');
		_G[Slider:GetName().."High"]:SetText('');
        _G["LeaPlusGlobalSlider" .. field] = nil

		-- Create slider label
		Slider.f = Slider:CreateFontString(nil, 'BACKGROUND')
		Slider.f:SetFontObject('GameFontHighlight')
		Slider.f:SetPoint('LEFT', Slider, 'RIGHT', 12, 0)
		Slider.f:SetFormattedText("%.2f", Slider:GetValue())

		-- Process mousewheel scrolling
		Slider:SetScript("OnMouseWheel", function(self, arg1)
			if Slider:IsEnabled() then
				local step = step * arg1
				local value = self:GetValue()
				if step > 0 then
					self:SetValue(min(value + step, high))
				else
					self:SetValue(max(value + step, low))
				end
			end
		end)

		-- Process value changed
		Slider:SetScript("OnValueChanged", function(self, value)
			local value = floor((value - low) / step + 0.5) * step + low
			Slider.f:SetFormattedText(form, value)
			LeaPlusLC[field] = value
		end)

		-- Set slider value when shown
		Slider:SetScript("OnShow", function(self)
			self:SetValue(LeaPlusLC[field])
		end)

	end

	-- Create a checkbox control (uses standard template)
	function LeaPlusLC:MakeCB(parent, field, caption, x, y, tip, tipstyle)

		-- Create the checkbox
		local Cbox = CreateFrame('CheckButton', nil, parent, "ChatConfigCheckButtonTemplate")
		LeaPlusCB[field] = Cbox
		Cbox:SetPoint("TOPLEFT",x, y)
		Cbox:SetHitRectInsets(0,-100,0,0)

		-- Add tooltip
		if tipstyle then
			if tipstyle == 2 then
				-- Tooltip positioned left of the checkbox
				Cbox:SetScript("OnEnter", function()
					if LeaPlusLC["PlusShowTips"] == "On" then
						GameTooltip:SetOwner(Cbox, "ANCHOR_LEFT", -10, -50)
						GameTooltip:SetText(tip, nil, nil, nil, nil, true)
					end
				end)
			elseif tipstyle == 3 then
				-- Tooltip positioned left of the checkbox with gap (for inset options)
				Cbox:SetScript("OnEnter", function()
					if LeaPlusLC["PlusShowTips"] == "On" then
						GameTooltip:SetOwner(Cbox, "ANCHOR_LEFT", -26, -50)
						GameTooltip:SetText(tip, nil, nil, nil, nil, true)
					end
				end)
			end
		else
			-- Tooltip positioned to the side of the panel
			Cbox.tiptext = tip
			Cbox:SetScript("OnEnter", LeaPlusLC.ShowTooltip)		
			Cbox:SetScript("OnLeave", GameTooltip_Hide)
		end

		-- Add label
		Cbox.f = Cbox:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Cbox.f:SetPoint('LEFT', 20, 0)
		Cbox.f:SetText(caption)

		-- Set default checkbox state and click area
		Cbox:SetScript('OnShow', function(self)
			self:SetChecked(LeaPlusLC[field])
			Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 10, 0, 0);
		end)

		-- Process clicks
		Cbox:SetScript('OnClick', function()
			if Cbox:GetChecked() == nil then
				LeaPlusLC[field] = "Off"
			elseif Cbox:GetChecked() == 1 then
				LeaPlusLC[field] = "On"
			end
			LeaPlusLC:SetDim(); -- Lock invalid options
			LeaPlusLC:ReloadCheck(); -- Show reload button if needed
			LeaPlusLC:Live(); -- Run live code
		end)
	end

	-- Create an editbox (uses standard template)
	function LeaPlusLC:CreateEditBox(frame, parent, width, maxchars, anchor, x, y, tab, shifttab)

		-- Create editbox
        local eb = CreateFrame("EditBox", "LeaPlus" .. frame, parent, "InputBoxTemplate")
		LeaPlusCB[frame] = eb
		eb:SetPoint(anchor, x, y)
		eb:SetWidth(width)
		eb:SetHeight(24)
		eb:SetFontObject("GameFontNormal")
		eb:SetTextColor(1.0, 1.0, 1.0)
		eb:SetAutoFocus(false) 
		eb:SetMaxLetters(maxchars) 
		eb:SetScript("OnEscapePressed", eb.ClearFocus)
		eb:SetScript("OnEnterPressed", eb.ClearFocus)

		-- Add editbox border and backdrop
		eb.f = CreateFrame("FRAME", nil, eb);
		eb.f:SetBackdrop(GameTooltip:GetBackdrop())
		eb.f:SetPoint("LEFT", -6, 0);
		eb.f:SetWidth(eb:GetWidth()+6);
		eb.f:SetHeight(eb:GetHeight())
		eb.f:SetBackdropColor(1.0, 1.0, 1.0, 0.3)

		-- Move onto next editbox when tab key is pressed
		eb:SetScript("OnTabPressed", function(self)
			LeaPlusLC[frame] = eb:GetText();
			LeaPlusDC[frame] = LeaPlusLC[frame];
			self:ClearFocus();
			if IsShiftKeyDown() then
				LeaPlusCB[shifttab]:SetFocus();
			else
				LeaPlusCB[tab]:SetFocus();
			end
		end)

		-- Load initial values
		if LeaPlusDC[frame] then
			eb:SetText(LeaPlusDC[frame]);
		end

		-- Remove global reference (was only needed for template)
        _G["LeaPlus" .. frame] = nil

		return eb

	end

	-- Create a standard button (using standard button template)
	function LeaPlusLC:CreateButton(name, frame, label, anchor, x, y, width, height, reskin, tip)
		local mbtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		LeaPlusCB[name] = mbtn
		mbtn:SetWidth(width)
		mbtn:SetHeight(height) 
		mbtn:SetAlpha(1.0)
		mbtn:SetPoint(anchor, x, y)
		mbtn:SetText(label) 
		mbtn:RegisterForClicks("AnyUp") 
		mbtn:SetHitRectInsets(0, 0, 0, 0);
		mbtn:SetFrameStrata("FULLSCREEN_DIALOG");
		mbtn:SetScript("OnEnter", LeaPlusLC.ShowTooltip)		
		mbtn:SetScript("OnLeave", GameTooltip_Hide)
		mbtn.tiptext = tip

		-- Texture the button
		if reskin then
			local function SetBtn()
				mbtn.Left:SetTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus_Up.blp")
				mbtn.Middle:SetTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus_Up.blp")
				mbtn.Right:SetTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus_Up.blp")
				mbtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Plus\\Leatrix_Plus_High.blp")
			end

			-- Texture the button
			mbtn:HookScript("OnShow", SetBtn)
			mbtn:HookScript("OnEnable", SetBtn)
			mbtn:HookScript("OnDisable", SetBtn)
			mbtn:HookScript("OnMouseDown", SetBtn)
			mbtn:HookScript("OnMouseUp", SetBtn)
		end

		return mbtn
	end

	-- Create a dropdown menu (using custom function to avoid taint)
	function LeaPlusLC:CreateDropDown(ddname, label, parent, width, anchor, x, y, items, tip)

		-- Add the dropdown name to a table
		tinsert(LeaDropList, ddname)

		-- Populate variable with item list
		LeaPlusLC[ddname.."Table"] = items

		-- Create outer frame
		local frame = CreateFrame("FRAME", nil, parent); frame:SetWidth(width); frame:SetHeight(42); frame:SetPoint("BOTTOMLEFT", parent, anchor, x, y);

		-- Create dropdown inside outer frame
		local dd = CreateFrame("Frame", nil, frame); dd:SetPoint("BOTTOMLEFT", -16, -8); dd:SetPoint("BOTTOMRIGHT", 15, -4); dd:SetHeight(32);

		-- Create dropdown textures
		local lt = dd:CreateTexture(nil, "ARTWORK"); lt:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame"); lt:SetTexCoord(0, 0.1953125, 0, 1); lt:SetPoint("TOPLEFT", dd, 0, 17); lt:SetWidth(25); lt:SetHeight(64); 
		local rt = dd:CreateTexture(nil, "BORDER"); rt:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame"); rt:SetTexCoord(0.8046875, 1, 0, 1); rt:SetPoint("TOPRIGHT", dd, 0, 17); rt:SetWidth(25); rt:SetHeight(64); 
		local mt = dd:CreateTexture(nil, "BORDER"); mt:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame"); mt:SetTexCoord(0.1953125, 0.8046875, 0, 1); mt:SetPoint("LEFT", lt, "RIGHT"); mt:SetPoint("RIGHT", rt, "LEFT"); mt:SetHeight(64);

		-- Create dropdown label
		local lf = dd:CreateFontString(nil, "OVERLAY", "GameFontNormal"); lf:SetPoint("TOPLEFT", frame, 0, 0); lf:SetPoint("TOPRIGHT", frame, -5, 0); lf:SetJustifyH("LEFT"); lf:SetText(label)
	
		-- Create dropdown placeholder for value (set it using OnShow)
		local value = dd:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		value:SetPoint("LEFT", lt, 26, 2); value:SetPoint("RIGHT", rt, -43, 0); value:SetJustifyH("LEFT")
		dd:SetScript("OnShow", function() value:SetText(LeaPlusLC[ddname.."Table"][LeaPlusLC[ddname]]) end)

		-- Create dropdown button (clicking it opens the dropdown list)
		local dbtn = CreateFrame("Button", nil, dd)
		dbtn:SetPoint("TOPRIGHT", rt, -16, -18); dbtn:SetWidth(24); dbtn:SetHeight(24)
		dbtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up"); dbtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down"); dbtn:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled"); dbtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight"); dbtn:GetHighlightTexture():SetBlendMode("ADD")
		dbtn.tiptext = tip; dbtn:SetScript("OnEnter", LeaPlusLC.ShowTooltip); 
		dbtn:SetScript("OnLeave", GameTooltip_Hide)

		-- Create dropdown list
		local ddlist =  CreateFrame("Frame",nil,frame);
		LeaPlusCB["ListFrame"..ddname] = ddlist;
		ddlist:SetPoint("TOP",0,-42);
		ddlist:SetWidth(frame:GetWidth());
		ddlist:SetHeight((#items * 17) + 17 + 17);
		ddlist:SetFrameStrata("FULLSCREEN_DIALOG");
		ddlist:SetFrameLevel(12);
		ddlist:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = false, tileSize = 0, edgeSize = 32, insets = { left = 4, right = 4, top = 4, bottom = 4 }});
		ddlist:Hide();

		-- Create checkmark (it marks the currently selected item)
		local ddlistchk = CreateFrame("FRAME", nil, ddlist)
		ddlistchk:SetHeight(16); ddlistchk:SetWidth(16);
		ddlistchk.t = ddlistchk:CreateTexture(nil, "ARTWORK"); ddlistchk.t:SetAllPoints(); ddlistchk.t:SetTexture("Interface\\Common\\UI-DropDownRadioChecks"); ddlistchk.t:SetTexCoord(0, 0.5, 0.5, 1.0);

		-- Create dropdown list items
		for k, v in pairs(items) do

			local dditem = CreateFrame("Button", nil, LeaPlusCB["ListFrame"..ddname])
			LeaPlusCB["Drop"..ddname..k] = dditem;
			dditem:Show();
			dditem:SetWidth(ddlist:GetWidth()-22)
			dditem:SetHeight(20)
			dditem:SetPoint("TOPLEFT", 12, -k*16)

			dditem.f = dditem:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight'); 
			dditem.f:SetPoint('LEFT', 16, 0)
			dditem.f:SetText(items[k])

			dditem.t = dditem:CreateTexture(nil, "BACKGROUND")
			dditem.t:SetAllPoints()
			dditem.t:SetTexture(0.3, 0.3, 0.00, 0.8)
			dditem.t:Hide();

			dditem:SetScript("OnEnter", function() dditem.t:Show() end)
			dditem:SetScript("OnLeave", function() dditem.t:Hide() end)
			dditem:SetScript("OnClick", function()
				LeaPlusLC[ddname] = k
				value:SetText(LeaPlusLC[ddname.."Table"][k])
				ddlist:Hide(); -- Must be last as other functions hook it
			end)

			-- Show list when button is clicked
			dbtn:SetScript("OnClick", function()
				-- Show the dropdown
				if ddlist:IsShown() then ddlist:Hide() else 
					ddlist:Show();
					ddlistchk:SetPoint("TOPLEFT",10,select(5,LeaPlusCB["Drop"..ddname..LeaPlusLC[ddname]]:GetPoint()))
					ddlistchk:Show();
				end;
				-- Hide all other dropdowns except the one we're dealing with
				for void,v in pairs(LeaDropList) do
					if v ~= ddname then
						LeaPlusCB["ListFrame"..v]:Hide();
					end
				end
			end)

			-- Expand the clickable area of the button to include the entire menu width
			dbtn:SetHitRectInsets(-width+28, 0, 0, 0);

		end

		return frame
		
	end
	
----------------------------------------------------------------------
-- 	L76: Create main options panel frame
----------------------------------------------------------------------

	function LeaPlusLC:CreateMainPanel()

		-- Create the options panel frame
		local PageF = CreateFrame("Frame", "LeaPlusGlobalPanel", UIParent);
		table.insert(UISpecialFrames, "LeaPlusGlobalPanel")
		LeaPlusLC["PageF"] = PageF
		PageF:SetSize(570,370)
		PageF:Hide();
		PageF:SetFrameStrata("FULLSCREEN_DIALOG")
		PageF:SetClampedToScreen(true);
		PageF:EnableMouse(true)
		PageF:SetMovable(true)
		PageF:RegisterForDrag("LeftButton")
		PageF:SetScript("OnDragStart", PageF.StartMoving)
		PageF:SetScript("OnDragStop", function ()
			PageF:StopMovingOrSizing();
			PageF:SetUserPlaced(false);
			-- Save panel position
			LeaPlusLC["MainPanelA"], void, LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"] = PageF:GetPoint()
		end)

		-- Add background color
		PageF.t = PageF:CreateTexture(nil, "BACKGROUND")
		PageF.t:SetAllPoints()
		PageF.t:SetTexture(0.05, 0.05, 0.05, 0.9)

		-- Set panel position when shown
		PageF:SetScript("OnShow", function()
			PageF:ClearAllPoints()
			PageF:SetPoint(LeaPlusLC["MainPanelA"], UIParent, LeaPlusLC["MainPanelR"], LeaPlusLC["MainPanelX"], LeaPlusLC["MainPanelY"])
		end)

		-- Add textures
		local function CreateBar(name, parent, width, height, anchor, r, g, b, alp, tex)
			local ft = parent:CreateTexture(nil, "BORDER")
			ft:SetTexture(tex)
			ft:SetSize(width, height)  
			ft:SetPoint(anchor)
			ft:SetVertexColor(r ,g, b, alp)
			if name == "MainTexture" then
				ft:SetTexCoord(0.09, 1, 0, 1);
			end
		end
		CreateBar("FootTexture", PageF, 570, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		CreateBar("MainTexture", PageF, 440, 328, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		CreateBar("MenuTexture", PageF, 130, 328, "TOPLEFT", 0.7, 0.7, 0.7, 0.7, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

		-- Add main title (shown above menu in the corner)
		PageF.mt = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		PageF.mt:SetPoint('TOPLEFT', 16, -16)
		PageF.mt:SetText("Leatrix Plus")

		-- Add version text (shown underneath main title)
		PageF.v = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		PageF.v:SetHeight(32);
		PageF.v:SetPoint('TOPLEFT', PageF.mt, 'BOTTOMLEFT', 0, -8); 
		PageF.v:SetPoint('RIGHT', PageF, -32, 0)
		PageF.v:SetJustifyH('LEFT'); PageF.v:SetJustifyV('TOP');
		PageF.v:SetNonSpaceWrap(true); PageF.v:SetText("Version " .. LeaPlusLC["AddonVer"])

		-- Add reload UI Button
		local reloadb = LeaPlusLC:CreateButton("ReloadUIButton", PageF, "Reload", "BOTTOMLEFT", 490, 10, 70, 25, true, "Your UI needs to be reloaded for some of the changes to take effect.\n\nYou don't have to click the reload button immediately but you do need to click it when you are done making changes and you want the changes to take effect.")
		LeaPlusLC:LockItem(reloadb,true)
		reloadb:SetScript("OnClick", ReloadUI)

		reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
		reloadb.f:SetHeight(32);
		reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
		reloadb.f:SetText("Your UI needs to be reloaded.")
		reloadb.f:Hide()

		-- Add close Button
		local CloseB = CreateFrame("Button", nil, PageF, "UIPanelCloseButton") 
		CloseB:SetSize(30, 30)
		CloseB:SetPoint("TOPRIGHT", 0, 0)
		CloseB:SetScript("OnClick", function() 
			LeaPlusLC:HideFrames();
		end)

		-- Release memory
		LeaPlusLC.CreateMainPanel = nil

	end

	LeaPlusLC:CreateMainPanel();

----------------------------------------------------------------------
-- 	L77: Create options panel pages (no content yet)
----------------------------------------------------------------------

	-- Function to add menu button
	function LeaPlusLC:MakeMN(name, text, parent, anchor, x, y, width, height)

		local mbtn = CreateFrame("Button", nil, parent)
		LeaPlusLC[name] = mbtn
		mbtn:Show();
		mbtn:SetSize(width, height)
		mbtn:SetAlpha(1.0)
		mbtn:SetPoint(anchor, x, y)

		mbtn.t = mbtn:CreateTexture(nil, "BACKGROUND")
		mbtn.t:SetAllPoints()
		mbtn.t:SetTexture(0.3, 0.3, 0.00, 0.8)
		mbtn.t:SetAlpha(0.7)
		mbtn.t:Hide()

		mbtn.s = mbtn:CreateTexture(nil, "BACKGROUND")
		mbtn.s:SetAllPoints()
		mbtn.s:SetTexture(0.3, 0.3, 0.00, 0.8)
		mbtn.s:Hide()

		mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		mbtn.f:SetPoint('LEFT', 16, 0)
		mbtn.f:SetText(text)
	
		mbtn:SetScript("OnEnter", function()
			mbtn.t:Show()
		end)

		mbtn:SetScript("OnLeave", function()
			mbtn.t:Hide()
		end)

		return mbtn, mbtn.s

	end

	-- Function to create individual options panel pages
	function LeaPlusLC:MakePage(name, title, menu, menuname, menuparent, menuanchor, menux, menuy, menuwidth, menuheight)

		-- Create frame
		local oPage = CreateFrame("Frame", nil, LeaPlusLC["PageF"]); 
		LeaPlusLC[name] = oPage
		oPage:SetAllPoints(LeaPlusLC["PageF"])
		oPage:Hide();

		-- Add page title
		oPage.s = oPage:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		oPage.s:SetPoint('TOPLEFT', 146, -16)
		oPage.s:SetText(title)

		-- Add menu item if needed
		if menu then
			LeaPlusLC[menu], LeaPlusLC[menu .. ".s"] = LeaPlusLC:MakeMN(menu, menuname, menuparent, menuanchor, menux, menuy, menuwidth, menuheight)
			LeaPlusLC[name]:SetScript("OnShow", function() LeaPlusLC[menu .. ".s"]:Show(); end)
			LeaPlusLC[name]:SetScript("OnHide", function() LeaPlusLC[menu .. ".s"]:Hide(); end)
		end

		return oPage;
	
	end

	-- Create options pages
	LeaPlusLC["Page0"] = LeaPlusLC:MakePage("Page0", "Home"			, "LeaPlusNav0", "Home"			, LeaPlusLC["PageF"], "TOPLEFT", 16, -72, 112, 20)
	LeaPlusLC["Page1"] = LeaPlusLC:MakePage("Page1", "Automation"	, "LeaPlusNav1", "Automation"	, LeaPlusLC["PageF"], "TOPLEFT", 16, -112, 112, 20)
	LeaPlusLC["Page2"] = LeaPlusLC:MakePage("Page2", "Interaction"	, "LeaPlusNav2", "Interaction"	, LeaPlusLC["PageF"], "TOPLEFT", 16, -132, 112, 20)
	LeaPlusLC["Page3"] = LeaPlusLC:MakePage("Page3", "Chat"			, "LeaPlusNav3", "Chat"			, LeaPlusLC["PageF"], "TOPLEFT", 16, -152, 112, 20)
	LeaPlusLC["Page4"] = LeaPlusLC:MakePage("Page4", "Text"			, "LeaPlusNav4", "Text"			, LeaPlusLC["PageF"], "TOPLEFT", 16, -172, 112, 20)
	LeaPlusLC["Page5"] = LeaPlusLC:MakePage("Page5", "Interface"	, "LeaPlusNav5", "Interface"	, LeaPlusLC["PageF"], "TOPLEFT", 16, -192, 112, 20)
	LeaPlusLC["Page6"] = LeaPlusLC:MakePage("Page6", "Miscellaneous", "LeaPlusNav6", "Misc"			, LeaPlusLC["PageF"], "TOPLEFT", 16, -212, 112, 20)
	LeaPlusLC["Page7"] = LeaPlusLC:MakePage("Page7", "System"		, "LeaPlusNav7", "System"		, LeaPlusLC["PageF"], "TOPLEFT", 16, -232, 112, 20)

	-- Create settings page
	LeaPlusLC["Page8"] = LeaPlusLC:MakePage("Page8", "Settings"		, "LeaPlusNav8", "Settings"	, LeaPlusLC["PageF"], "TOPLEFT", 16, -272, 112, 20)

	-- Page navigation mechanism
	for i = 0, LeaPlusLC["NumberOfPages"] do
		LeaPlusLC["LeaPlusNav"..i]:SetScript("OnClick", function()
			LeaPlusLC:HideFrames()
			LeaPlusLC["PageF"]:Show();
			LeaPlusLC["Page"..i]:Show();
			LeaPlusLC["LeaStartPage"] = i
		end)
	end

	-- Use a variable to contain the page number (makes it easier to move options around)
	local pg;

----------------------------------------------------------------------
-- 	L80: Page 0 - Welcome
----------------------------------------------------------------------

	pg = "Page0";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Welcome to Leatrix Plus, " .. UnitName("player") .. ".", 146, -72);
	LeaPlusLC:MakeWD(LeaPlusLC[pg], "To begin, choose an options page.", 146, -92);

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Support", 146, -132);
	LeaPlusLC:MakeWD(LeaPlusLC[pg], "www.leatrix.com", 146, -152);

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Tip", 146, -266);
	LeaPlusLC:MakeWD(LeaPlusLC[pg], "Click |TInterface\\WorldMap\\Gear_64.png:20:20:0:0:32:32:0:16:0:16|t buttons to access additional configuration options.", 146, -286);

----------------------------------------------------------------------
-- 	L81: Page 1: Automation
----------------------------------------------------------------------

	pg = "Page1";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Party Automation"			, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AcceptPartyFriends"		, 	"Party from friends"			, 	146, -92, 	"If checked, party invitations from friends will be automatically accepted unless you are queued in Dungeon Finder.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoConfirmRole"			, 	"Dungeon groups"				,	146, -112, 	"If checked, requests initiated by your party leader to join the Dungeon Finder queue will be automatically accepted if the party leader is in your friends list.\n\nEnabling this option does not port you into the dungeon automatically.\n\nThis option requires that you have selected a role for your character in the Dungeon Finder window.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "InviteFromWhisper"			,   "Invite from whispers"			,	146, -132,	"This tooltip is replaced by the option code")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Character Automation"		, 	146, -172);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoReleaseInBG"			,	"Release in battlegrounds"		, 	146, -192, 	"If checked, you will release automatically after you die in a battleground unless you are protected by a soulstone.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoAcceptSummon"			,	"Accept summon"					, 	146, -212, 	"If checked, summon requests will be accepted automatically unless you are in combat.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoAcceptRes"				,	"Accept resurrect"				, 	146, -232, 	"If checked, resurrection attempts cast on you will be accepted automatically.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoAutoResInCombat"			,	"Exclude combat res"			, 	166, -252, 	"If checked, resurrection attempts cast on you will not be automatically accepted if the player resurrecting you is in combat.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Blockers"					, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoDuelRequests"			, 	"Block duels"					,	340, -92, 	"If checked, duel requests will be blocked unless the player requesting the duel is in your friends list.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoPetDuels"				, 	"Block pet battle duels"		,	340, -112, 	"If checked, pet battle duel requests will be blocked unless the player requesting the duel is in your friends list.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoPartyInvites"			, 	"Block party invites"			, 	340, -132, 	"If checked, party invitations will be blocked unless the player inviting you is in your friends list.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Blizzard Blockers"			, 	340, -172);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ManageTradeGuild"			,   "Manage blockers*"				,	340, -192,	"If checked, you will be able to configure trade request and guild invitation and petition blocking using the two settings below.\n\nThese are replacements for Blizzard's trade and guild invitation blocking options to make them account-wide.\n\n* Requires UI reload.  After the reload, the checkbox controls below will be available.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoTradeRequests"			, 	"Block trades"					, 	360, -212, 	"If checked, trade requests will be blocked.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoGuildInvites"			,	"Block guild invites"			,	360, -232, 	"If checked, guild invitations and petitions will be blocked.\n\nIf you are in the process of making your own guild, you need to uncheck this box to see your own petition.")

 	LeaPlusLC:CfgBtn("InvWhisperBtn", LeaPlusCB["InviteFromWhisper"], "Click to change the keyword.")

----------------------------------------------------------------------
-- 	L82: Page 2: Interaction
----------------------------------------------------------------------

	pg = "Page2";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Vendors"					, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoSellJunk"				,	"Sell junk automatically"		,	146, -92, 	"If checked, all grey items in your bags will be automatically sold when you visit a merchant.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoRepairOwnFunds"		, 	"Automatically repair"			,	146, -112, 	"If checked, your armor will be automatically repaired when you visit a suitable merchant.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoRepairGuildFunds"		,	"Use guild funds"				,	166, -132,	"If checked, repair costs will be taken from guild funds for characters that are guilded and have permission to repair.\n\nIf available guild funds have not been cached by the client yet, a blind repair will be attempted.\n\nIf the guilded character does not have permission to repair or not enough guild funds are available, the character's own funds will be used.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoBagAutomation"			,   "Prevent bag automation*"		,	146, -152,	"If checked, your bags will not be opened and closed automatically when you use a vendor or mailbox.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AhExtras"					, 	"Auction house extras*"			, 	146, -172, 	"If checked, additional functionality will be added to the auction house.\n\nBuyout only - create buyout auctions without filling in the starting price.\n\nGold only - set the copper and silver prices at 99 to speed up new auctions.\n\nFind - search the auction house for the item you are selling.\n\nIn addition, the auction duration setting will be saved account-wide.\n\n* Requires UI reload.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Groups"					, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoRaidRestrictions"		, 	"Remove raid restrictions*"		,	340, -92, 	"If checked, your low level characters will be allowed to join raid groups.\n\nNote that you cannot join a raid group directly with a low level character.  You have to join a party group first then the party leader should convert the party group to a raid group.\n\nReload your UI if the group leader is unable to convert the party group to a raid group.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "RoleSave"					,	"Save dungeon roles*"			,	340, -112,	"If checked, a button will be added to the Dungeon Finder window which will allow you to save your currently selected group roles to your talent spec.\n\nThese roles will then be selected automatically when you switch specs.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowRaidToggle"			, 	"Show raid toggle button*"		,	340, -132, 	"If checked, the button to toggle the raid container frame will be shown just above the raid management frame (left side of the screen) instead of in the raid management frame itself.\n\nThis allows you to toggle the raid container frame without needing to open the raid management frame.\n\nThe button will only show while you are in a raid.\n\n* Requires UI reload.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Loot Alerts"				, 	340, -172);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoConfirmLoot"				, 	"Hide loot warnings"			,	340, -192, 	"If checked, confirmations which appear when you choose a loot roll option (need, greed or disenchant) will not be shown.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoLootWonAlert"			, 	"Hide loot won alerts*"			,	340, -212, 	"If checked, the loot won alert will not be shown when you win loot while in a group.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "SoilAlert"					, 	"Dark Soil alert*"				,	340, -232, 	"If checked, a raid warning will sound when you hover the mouse pointer over a Dark Soil object.\n\n* Requires UI reload.")

----------------------------------------------------------------------
-- 	L83: Page 3: Chat
----------------------------------------------------------------------

	pg = "Page3";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "General"					, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UseEasyChatResizing"		,	"Use easy resizing*"			,	146, -92,	"If checked, dragging the General chat tab while the chat frame is locked will expand the chat frame upwards.\n\n\If the chat frame is unlocked, dragging the General chat tab will move the frame as normal.\n\nThis is a very useful option that enables you to quickly see more of the recent chat text when required (such as damage meters, loot rolls, etc).\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoCombatLogTab" 			, 	"Hide the combat log*"			, 	146, -112, 	"If checked, the combat log will be hidden.\n\nThis option won't disable combat log functionality so addons which parse the combat log will still function correctly.\n\nThe combat log must be docked in order for this option to work.  If the combat log is undocked, you can dock it by dragging the tab (and reloading your UI) or by resetting the chat windows (from the chat menu).\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoChatButtons"				,	"Hide chat buttons*"			,	146, -132,	"If checked, chat frame buttons will be hidden.\n\nClicking chat tabs will automatically show the latest messages.\n\nUse the mouse wheel to scroll through the chat history.  Hold down SHIFT for page jump or CTRL to jump to the top or bottom of your chat history.\n\nEnabling this option also enables the Blizzard mouse scrolling option (social menu) and prevents you from changing it.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UnclampChat"				,	"Unclamp chat frame*"			,	146, -152,	"If checked, you will be able to drag the chat frame to the edge of the screen.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MoveChatEditBoxToTop" 		, 	"Move editbox to top*"			,	146, -172, 	"If checked, the editbox will be moved to the top of the chat frame.\n\n* Requires UI reload.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Mechanics"					, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoStickyChat"				, 	"Disable sticky chat*"			,	340, -92,	"If checked, you can press enter to talk in group chat using whatever method you used last (say, party, guild, etc).\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UseArrowKeysInChat"		, 	"Use arrow keys in chat*"		, 	340, -112, 	"If checked, you can press the arrow keys to move the insertion point left and right in the chat frame.\n\nIf unchecked, the arrow keys will use the default keybind setting.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoChatFade"				, 	"Disable chat fade*"			, 	340, -132, 	"If checked, chat text will not fade out after a time period.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MaxChatHstory"				,	"Increase chat history*"		, 	340, -152, 	"If checked, your chat history will increase to 4096 lines.  If unchecked, the default will be used (128 lines).\n\nEnabling this option may prevent some chat text from showing during login.\n\n* Requires UI reload.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Chat Colors"				, 	340, -192);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "UnivGroupColor"			,	"Universal group color*"		,	340, -212,	"If checked, raid chat and instance chat will both be colored blue (to match the default party chat color).\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "Manageclasscolors"			,	"Manage class colors*"			,	340, -232,	"If checked, you will be able to configure class-coloring in the chat frame using the two settings below.\n\nThis is a replacement for Blizzard's class coloring options to make them simpler and account-wide.\n\n* Requires UI reload.  After the reload, the checkbox controls below will be available.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ColorLocalChannels"		, 	"Local channel colors"			, 	360, -252, 	"If checked, names will be shown in class color in local channels (such as say, party, raid, etc).\n\nIf unchecked, names will be shown in normal chat color.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ColorGlobalChannels"		, 	"Global channel colors"			,	360, -272, 	"If checked, names will be shown in class color in global channels (such as general, trade, etc).\n\nIf unchecked, names will be shown in normal chat color.")

----------------------------------------------------------------------
-- 	L84: Page 4: Text
----------------------------------------------------------------------

	pg = "Page4";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Zone Text"					, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideZoneText"				,	"Hide zone text*"				,	146, -92, 	"If checked, zone text will not be shown (eg. 'Ironforge').\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideSubzoneText"			, 	"Hide subzone text*"			,	146, -112, 	"If checked, subzone text will not be shown (eg. 'Mystic Quarter').\n\n* Requires UI reload.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Combat Text"				, 	146, -152);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoHitIndicators"			, 	"Hide portrait text*"			,	146, -172, 	"If checked, damage and healing numbers in the player and pet portrait frames will be hidden.\n\n* Requires UI reload.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Error Text"				, 	146, -212);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "HideErrorFrameText"		, 	"Hide error messages*"			,	146, -232, 	"If checked, error messages (eg. 'Not enough rage') will not be shown in the error frame.\n\nCertain important errors (such as Inventory full, quest log full and votekick errors) will be shown regardless of this setting.\n\nIf you have the minimap button enabled, you can right-click it to toggle error messages without affecting this setting.\n\n* Requires UI reload.  After the reload, the checkbox control below will be available.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowQuestUpdates"			, 	"Show quest updates"			, 	166, -252, 	"If checked, quest updates will be shown in the error frame.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Mail Text"					, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MailFontChange"			,	"Resize mail text*"				, 	340, -92, 	"If checked, the font used for standard mail will be resized according to the value set by the slider.\n\nIn addition, the text itself will be easier to read.\n\nThis does not affect mail created using templates (such as auction house invoices).\n\n* Requires UI reload.  After the reload, the slider control below will be available.")
	LeaPlusLC:MakeSL(LeaPlusLC[pg], "LeaPlusMailFontSize"		, 	"",	10, 36, 1, 364, -122, "%.0f")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Quest Detail Text"			, 	340, -162);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "QuestFontChange"			,	"Resize quest detail text*"		, 	340, -182, 	"If checked, quest detail text will be resized according to the value set by the slider.\n\nEnabling this option will also change the text size on other frames which inherit the same font (such as the Dungeon Finder frame).\n\n* Requires UI reload.  After the reload, the slider control below will be available.")
	LeaPlusLC:MakeSL(LeaPlusLC[pg], "LeaPlusQuestFontSize"		, 	"",	10, 36, 1, 364, -212, "%.0f")

----------------------------------------------------------------------
-- 	L86: Page 5: Interface
----------------------------------------------------------------------

	pg = "Page5";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "World Map"					, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowMapMod"				, 	"Enable customisation*"			, 	146, -92, 	"If checked, you will be able to customise the world map with features such as changing the scale, showing map coordinates and revealing unexplored areas.\n\nZoom in by left-clicking a location and zoom out by right-clicking any area.  Use the scrollwheel to traverse floors.\n\n* Requires UI reload.  After the reload, a configuration button will be available to the right and a checkbox will be added to the world map.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Minimap"					, 	146, -132);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "MinimapMod"				,	"Enable customisation*"			, 	146, -152, 	"If checked, you will be able to customise the minimap with features such as changing the scale and hiding various minimap components.\n\n* Requires UI reload.  After the reload, a configuration button will be available to the right.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Frames"					, 	146, -192);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "FrmEnabled"				,	"Enable customisation*"			, 	146, -212, 	"If checked, you will be able to change the position and scale of the player frame, target frame, world state, ghost frame and timer bar.  Your layout will be saved account-wide.\n\n* Requires UI reload.  After the reload, a configuration button will be available to the right.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Controls"					, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowVanityButtons"			,	"Show vanity controls*"			, 	340, -92, 	"If checked, two buttons will be added to the character sheet to allow you to toggle your helm and cloak easily.\n\nThe boxes can be placed in either of two locations on the character sheet.  To toggle between them, hold down SHIFT and right-click either checkbox.\n\nNote that there is a small delay after clicking a checkbox before it takes effect.  If you toggle the checkboxes too quickly, they may seem to stop working.  If that happens, just wait a few seconds.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowVolume"				, 	"Show volume control*"			, 	340, -112, 	"If checked, a master volume slider will be shown in the character sheet.\n\nThe volume control can be placed in either of two locations on the character sheet.  To toggle between them, hold down SHIFT and right-click it.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowDressTab"				, 	"Show dressup buttons*"			, 	340, -132, 	"If checked, buttons will be added to the dressup frame which will allow you to hide your tabard or appear nude.\n\n* Requires UI reload.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Information"				, 	340, -172);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "StaticCoordsEn"			, 	"Show coordinates*"				, 	340, -192, 	"If checked, coordinates representing your character's location will be shown in a movable, customisable frame.\n\n* Requires UI reload.  After the reload, a configuration button will be available to the right.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowSpellIcons"			, 	"Show spell icons*"				, 	340, -212, 	"If checked, you will be able to place up to five beneficial spell icons above the target or player frame.\n\nThis option is designed for watching spell cooldowns (such as a hunter's Mend Pet spell or a mage's Ice Barrier spell).\n\nEnabling this option will prevent you from using the Blizzard option to place buffs above the target frame.\n\n* Requires UI reload.  After the reload, a configuration button will be available to the right.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "DurabilityStatus"			, 	"Show durability status*"		, 	340, -232, 	"If checked, your equipped item durability status will be shown when you hover over the expand button on the character sheet (bottom-right corner).\n\nIn addition, an overall percentage will be shown in the chat frame when you die.\n\n* Requires UI reload.")

	LeaPlusLC:CfgBtn("MapOptBtn", LeaPlusCB["ShowMapMod"], "Click to modify the world map settings.")
	LeaPlusLC:CfgBtn("ModMinimapBtn", LeaPlusCB["MinimapMod"], "Click to modify the minimap settings.")
	LeaPlusLC:CfgBtn("MoveFramesButton", LeaPlusCB["FrmEnabled"], "Click to modify the frame settings.\n\nTo move a frame, simply drag it to a new location.\n\nTo change the scale of a frame, click to highlight it (green tint) then drag the scale slider.\n\nClicking the reset button will reset all frame positions and scales.")
	LeaPlusLC:CfgBtn("SpellIconsBtn", LeaPlusCB["ShowSpellIcons"], "Click to modify the spell icons.\n\nEnter the spell ID for each of the spell icons that you want to see.  Spell IDs are shown in the tooltips of beneficial spell icons in the buff frame and under the target frame.\n\nIf you want the spell icon to show only when the spell is stacked, enter the minimum number of stacks required (otherwise leave it blank).\n\nIf the spell icon normally appears under the pet frame, check the pet checkbox.")
	LeaPlusLC:CfgBtn("ModStaticCoordsBtn", LeaPlusCB["StaticCoordsEn"], "Click to modify the coordinates settings.")

----------------------------------------------------------------------
-- 	L87: Page 6: Miscellaneous
----------------------------------------------------------------------

	pg = "Page6";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Quests"					, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowQuestLevels"			,	"Show quest levels*"			,	146, -92, 	"If checked, quest levels will be shown in the quest log.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoAcceptQuests"			, 	"Accept quests"					,	146, -112, 	"If checked, quests will be accepted automatically.\n\nYou can hold the shift key down when you talk to a quest giver to over-ride this setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AcceptOnlyDailys"			, 	"Restrict to dailies"			, 	166, -132, 	"If checked, only daily quests will be accepted automatically.\n\nYou can hold the shift key down when you talk to a quest giver to over-ride this setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoTurnInQuests"			,	"Turn-in quests"				,	146, -152, 	"If checked, quests will be turned-in automatically.\n\nYou can hold the shift key down when you talk to a quest giver to over-ride this setting.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "TurnInOnlyDailys"			,	"Restrict to dailies"			,	166, -172, 	"If checked, only daily quests will be turned-in automatically.\n\nYou can hold the shift key down when you talk to a quest giver to over-ride this setting.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Tooltip"					, 	146, -212);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "TipModEnable"				,	"Enable customisation*"			,	146, -232, 	"If checked, the tooltip will be color coded and you will be able to modify the tooltip layout and scale.\n\n* Requires UI reload.  After the reload, a configuration button will be available to the right and the checkbox control below will be available.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "TipAnchorToMouse"			, 	"Anchor to mouse*"				,	166, -252, 	"If checked, tooltips will be anchored to the mouse pointer for units in the game world.\n\n* Requires UI reload.  After the reload, a configuration button will be available to the right.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Visibility"				, 	340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoGryphons"				,	"Hide gryphons*"				, 	340, -92, 	"If checked, the Blizzard gryphons will not be shown either side of the main bar.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoClassBar"				,	"Hide stance bar*"				, 	340, -112, 	"If checked, the stance bar will not be shown.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoCharControls"			,	"Hide character controls*"		,	340, -132, 	"If checked, control buttons (such as zoom) will not be shown at the top of the character frame, dressup frame and transmogrification frame.\n\n* Requires UI reload.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Features"					, 	340, -172);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AutoEnName"				, 	"Toggle enemy plates*"			,	340, -192, 	"If checked, enemy nameplates will be enabled automatically when you enter combat and disabled when combat ends.\n\n* Requires UI reload.  After the reload, a configuration button will be available to the right.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ClassColPlayer"			, 	"Player in class color*"		,	340, -212, 	"If checked, the player frame background will be shown in class color.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ClassColTarget"			, 	"Target in class color*"		,	340, -232, 	"If checked, the target and focus frame backgrounds will be shown in class color.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowPlayerChain"			, 	"Show player chain*"			,	340, -252, 	"If checked, you will be able to show a rare, elite or rare elite chain around the player frame.\n\n* Requires UI reload.  After the reload, a configuration button will be available to the right.")

	LeaPlusLC:CfgBtn("MoveTooltipButton", LeaPlusCB["TipModEnable"], "Click to modify the tooltip settings.  Move the tooltip by dragging the blue overlay frame.")
	LeaPlusLC:CfgBtn("ModTipMouseBtn", LeaPlusCB["TipAnchorToMouse"], "Click to change the anchor to mouse pointer settings.\n\nYou can change the tooltip anchor (this is the fixed part of the tooltip), the offsets (distance from the pointer) and the alpha setting (transparency).\n\nIn addition, you can hide tooltips during combat.  If you enable this option, you can show tooltips temporarily by holding down the SHIFT key.\n\nNote that anchor to mouse settings apply only to tooltips in the game world and not to the UI.")
	LeaPlusLC:CfgBtn("ModEnPanelBtn", LeaPlusCB["AutoEnName"], "Click to modify the enemy nameplate settings.")
	LeaPlusLC:CfgBtn("ModPlayerChain", LeaPlusCB["ShowPlayerChain"], "Click to modify the player chain settings.")

----------------------------------------------------------------------
-- 	L88: Page 7: System
----------------------------------------------------------------------

	pg = "Page7";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Graphics"					, 	146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoDeathEffect"				, 	"Hide death effect"				, 	146, -92, 	"If checked, the death effect will not be shown.\n\nThis is the grey screen glow that appears while your character is a ghost.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoSpecialEffects"			, 	"Hide special effects"			, 	146, -112, 	"If checked, the netherworld effect (such as mage Invisibility) and special effects (such as the mist in Borean Tundra) will not be shown.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoGlowEffect"				, 	"Remove screen glow"			, 	146, -132, 	"If checked, the screen glow will not be shown.\n\nThis is useful if you find the screen to be too bright.\n\nIt also has a handy side effect in that it blocks the blurry haze effect while your character is drunk.\n\nEnabling this option may increase your overall graphics performance significantly.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ManageZoomLevel"			, 	"Max camera distance*"			,	146, -152, 	"If checked, you will be able to zoom the camera out to a greater distance.\n\nThis can help with lots of encounters where you need to see more of the area around you.\n\nEnabling this option will prevent you from changing the camera distance setting in the Blizzard options panel.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ViewPortEnable"			,	"Enable viewport*"				,	146, -172, 	"If checked, you will be able to create a viewport.  A viewport adds adjustable black borders around the game world.\n\nThe borders are placed on top of the game world but under the UI so you can place UI elements over them.\n\nIn addition, you will be able to resize the game world to fit between the top and bottom borders if you wish.\n\n* Requires UI reload.  After the reload, a configuration button will be available to the right.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Sound"						, 	146, -212);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ManageRestedEmotes"		, 	"Manage emote sounds*"			,	146, -232, 	"If checked, you will be able to specify whether Leatrix Plus should automatically disable emote sounds while your character is resting.\n\nIf unchecked, you will need to manually control emote sounds using the Blizzard options panel.\n\nIf you enable this option, you will not be able to change the emote sound setting in the Blizzard options panel.\n\n* Requires UI reload.  After the reload, the checkbox control below will be available.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "NoSoundRested"				, 	"Silence rested emotes"			, 	166, -252, 	"If checked, emote sounds (such as laughing) will be silenced while your character is:\n\n- resting\n- at the Halfhill Market\n- at the Grim Guzzler\n\nEmote sounds will be enabled automatically when none of the above apply.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Privacy", 340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "AchieveControl"			, 	"Manage privacy*"				,	340, -92, 	"If checked, you will be able to configure how achievement points are shown to players inspecting you.\n\nIf unchecked, you will need to use the Blizzard setting (in the Display menu) on a per character basis.\n\nThis is a replacement for the Blizzard options panel setting to make it account-wide.\n\n* Requires UI reload.  After the reload, the checkbox control below will be available.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "CharOnlyAchieves"			, 	"Protect privacy"				,	360, -112, 	"If checked, only your character's achievement points will be shown to players inspecting you.\n\nIf unchecked, the totals shown will include all characters on your Battle.net account.\n\n* Requires UI reload.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Battle.net"				, 	340, -152);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ManageBnetReq"				, 	"Manage friend requests*"		, 	340, -172, 	"If checked, you will be able to configure BattleTag and Real ID friend request blocking using the setting below.\n\n* Requires UI reload.  After the reload, the checkbox control below will be available.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "BlockBnetReq"				, 	"Block friend requests"			, 	360, -192, 	"If checked, BattleTag and Real ID friend requests will be automatically declined.\n\nEnabling this option will automatically decline any pending requests.")

	LeaPlusLC:CfgBtn("ModViewportBtn", LeaPlusCB["ViewPortEnable"], "Click to modify the viewport settings.")

----------------------------------------------------------------------
-- 	L89: Settings
----------------------------------------------------------------------

	pg = "Page8";

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Settings"					, 146, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowMinimapIcon"			, "Show minimap button*"			, 146, -92,		"If checked, a minimap button will be available.\n\nLeft-click - Toggle options.\n\nRight-click - Toggle errors (if enabled, red while showing).\n\nSHIFT/Left-click - Toggle music.\n\nSHIFT/Right-click - Toggle coordinates (if enabled).\n\nCTRL/Left-click - Toggle minimap target tracking.\n\nCTRL/SHIFT/Left-click - Toggle Zygor (if installed)\n\nCTRL/SHIFT/Right-click - Toggle windowed mode.\n\n* Requires UI reload.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "ShowStartTag"				, "Show startup message"			, 146, -112, 	"If checked, the addon name and version will be shown in chat when you login or reload your UI.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "VersionChecker"			, "Show version warning"			, 146, -132, 	"If checked, a warning will be shown on startup if the version of Leatrix Plus that you are using was designed for an older World of Warcraft content patch.\n\nNote that this will only check for major version differences (such as using Leatrix Plus 5.1.xx with World of Warcraft 5.2.xx).\n\nIt will not check to confirm that you are using the very latest version of Leatrix Plus.\n\nIt's recommended that you leave this box checked unless you are using Leatrix Plus with the public test realm.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "OpenPlusAtHome"			, "Show home on startup"			, 146, -152, 	"If checked, the home page will always be shown when you open Leatrix Plus.\n\nIf unchecked, Leatrix Plus will open with the page that you were on when you last closed it.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Tooltips"					, 146, -192);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "PlusShowTips"				, "Show option tooltips"			, 146, -212, 	"If checked, tooltips will be shown for all of the checkboxes and buttons in the Leatrix Plus options panel.\n\nThe tooltips will be placed on the right side of the options panel.")
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "PanelTipAnchor"			, "On the left side"				, 166, -232, 	"If checked, tooltips will be placed on the left side of the options panel instead of the right.")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Panel Alpha"				, 340, -72);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "PlusPanelAlphaCheck"		, "Modify panel alpha"				, 340, -92, 	"If checked, you will be able to change the alpha (transparency) of the options panel.  If unchecked, the normal alpha will be used.")
	LeaPlusLC:MakeSL(LeaPlusLC[pg], "LeaPlusAlphaValue", "", 0.0, 1.0, 0.1, 364, -122, "%.1f")

	LeaPlusLC:MakeTx(LeaPlusLC[pg], "Panel Scale"				, 340, -162);
	LeaPlusLC:MakeCB(LeaPlusLC[pg], "PlusPanelScaleCheck"		, "Modify panel scale"				, 340, -182, 	"If checked, you will be able to change the scale of the options panel.  If unchecked, the normal scale will be used.")
	LeaPlusLC:MakeSL(LeaPlusLC[pg], "LeaPlusScaleValue", "", 0.5, 1.7, 0.1, 364, -212, "%.1f")

	LeaPlusLC:ShowMemoryUsage(LeaPlusLC[pg], "TOPLEFT", 340, -286)
