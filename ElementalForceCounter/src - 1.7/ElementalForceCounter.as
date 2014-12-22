import com.GameInterface.Game.Character;
import com.Utils.Archive;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;

var m_EF:MovieClip;

var m_ClientCharacter:Character;


//Crap for Viper's Bar

var m_Icon:MovieClip;
var m_VTIOIsLoadedMonitor:DistributedValue;
var m_OptionWindowState:DistributedValue;

var m_CompassCheckTimerID:Number;
var m_CompassCheckTimerLimit:Number = 256;
var m_CompassCheckTimerCount:Number = 0;

var VTIOAddonInfo:String = "Elemental Force Counter|Belladawna|1.7||_root.elementalforcecounter\\elementalforcecounter.m_Icon";

function OnModuleActivated(config:Archive) 
{
	//com.GameInterface.UtilsBase.PrintChatText("ModuleActivated");
	//com.GameInterface.UtilsBase.PrintChatText(config.FindEntry("x"));
	if (config.FindEntry("x")) {
		m_EF._x = config.FindEntry("x");
		m_EF._y = config.FindEntry("y");
		EFSize = config.FindEntry("xscale");
		m_EF._xscale = (m_EF._yscale = EFSize);
		//com.GameInterface.UtilsBase.PrintChatText("Loaded saved settings");
	}
	else
	{
		m_EF._x = 400;
		m_EF._y = 50;
		//com.GameInterface.UtilsBase.PrintChatText("New Settings");
	}
	
}

function onLoad()
{
	m_EF.border._visible = false;
	m_EF.counter.text = 0;
	
	var isMP = 0

	m_EF.onMousePress = function (buttonID) {
		//com.GameInterface.UtilsBase.PrintChatText(buttonID);
		if (Key.isDown(16)) {
			this.startDrag();
		} else if (buttonID == 2) {
			// code here to swap MP
			//com.GameInterface.UtilsBase.PrintChatText("ALT Held");
			/*if (isMP == 0) {
				isMP = 1;
				com.GameInterface.Chat.SignalShowFIFOMessage.Emit("Click to reset: <font color='#FF0000'>disabled</font>", 0);
			} else {
				isMP = 0;
				com.GameInterface.Chat.SignalShowFIFOMessage.Emit("Click to reset: <font color='#00FFFF'>enabled</font>", 0);
			}*/
		} else {
			var isInCombat:Boolean = m_ClientCharacter.IsInCombat();
			if (com.GameInterface.SpellBase.IsPassiveEquipped(6307518) && !isInCombat && isMP == 0) {
				ResetEF();
			}
			if (com.GameInterface.SpellBase.IsPassiveEquipped(6307518) && isInCombat) {
				com.GameInterface.Chat.SignalShowFIFOMessage.Emit("Can't Reset Elemental Force in Combat", 0);
			}
		}
	};

	m_EF.onRelease = m_EF.onReleaseOutside = function()
	{
		this.stopDrag();
	}
	
	m_EF.onMouseWheel = function (d) {
		if (Key.isDown(16)) {
			var EFSize = m_EF._xscale;
			EFSize = EFSize + (3 * d);
			if (EFSize < 50) {
  		      	EFSize = 50;
			}
   		    if (EFSize > 400) {
            	EFSize = 400;
            }
        m_EF._xscale = (m_EF._yscale = EFSize);
		SaveSettings();
		}
	}
	
	
	m_ClientCharacter = Character.GetClientCharacter();
	
	m_ClientCharacter.SignalBuffAdded.Connect(SlotBuffAdded, this);
	m_ClientCharacter.SignalBuffUpdated.Connect(SlotBuffChanged, this);
	m_ClientCharacter.SignalBuffRemoved.Connect(SlotBuffRemoved, this);
	
	
	//Crap for Viper's Bar
	
	// Setting up the VTIO loaded monitor.
	m_VTIOIsLoadedMonitor = DistributedValue.Create("VTIO_IsLoaded");
	m_VTIOIsLoadedMonitor.SignalChanged.Connect(SlotCheckVTIOIsLoaded, this);
	
	
	// Setting up the monitor for your option window state.
	m_OptionWindowState = DistributedValue.Create("BigMailIcon_OptionWindowOpen");
	m_OptionWindowState.SignalChanged.Connect(SlotOptionWindowState, this);
	
	// Make sure the game doesn't think the window is open if the game was reloaded with it open. Can also be placed in OnModuleDeactivated() if that's used.
	DistributedValue.SetDValue("BigMailIcon_OptionWindowOpen", false);

	// Setting up your icon.
	m_Icon = attachMovie("Icon", "m_Icon", getNextHighestDepth());
	m_Icon._width = 18;
	m_Icon._height = 18;
	m_Icon.onMousePress = function(buttonID) {
		if (buttonID == 1) {
			// Do left mouse button stuff.  Hide/Unhide window
			if (isMP == 0) {
				isMP = 1;
				com.GameInterface.Chat.SignalShowFIFOMessage.Emit("Click to reset: <font color='#FF0000'>disabled</font>", 0);
			} else {
				isMP = 0;
				com.GameInterface.Chat.SignalShowFIFOMessage.Emit("Click to reset: <font color='#00FFFF'>enabled</font>", 0);
			}
		} else if (buttonID == 2) {
			// Do right mouse button stuff.  Options window
			//if (m_Tooltip != undefined)	m_Tooltip.Close();
			//DistributedValue.SetDValue("BigMailIcon_OptionWindowOpen", !DistributedValue.GetDValue("BigMailIcon_OptionWindowOpen"));
		}
	}

	m_Icon.onRollOver = function() {
		if (m_Tooltip != undefined) m_Tooltip.Close();
        var tooltipData:TooltipData = new TooltipData();
		tooltipData.AddAttribute("", "<font face='_StandardFont' size='13' color='#FF8000'><b>Elemental Force Counter</b></font>");
        tooltipData.AddAttributeSplitter();
        tooltipData.AddAttribute("", "");
        tooltipData.AddAttribute("", "<font face='_StandardFont' size='12' color='#FFFFFF'>Code fork by Belladawna.  Orginal code by Nari, www.modcoder.com.\n\nLeft Click to toggle click to reset.  Right click to do noting.</font>");
        tooltipData.m_Padding = 4;
        tooltipData.m_MaxWidth = 210;
		m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, 0, tooltipData);
	}
	m_Icon.onRollOut = function() {
		if (m_Tooltip != undefined)	m_Tooltip.Close();
	}

	// Start the compass check.
	m_CompassCheckTimerID = setInterval(PositionIcon, 100);
	PositionIcon();

	// Check if VTIO is loaded (if it loaded before this add-on was).
	SlotCheckVTIOIsLoaded();
	
	//m_ClientCharacter.SignalInvisibleBuffAdded.Connect(IBuffAdded, this);
	//m_ClientCharacter.SignalInvisibleBuffUpdated.Connect(IBuffChanged, this);
	
	
}

function SlotBuffChanged(buffId:Number)
{
	switch(buffId)
	{
		case 6497060:
			//com.GameInterface.UtilsBase.PrintChatText("Buff1 Updated");
			this.m_EF.counter.text = this.m_ClientCharacter.m_BuffList[buffId].m_Count;
			this.m_EF.border._visible = false;
			break;
		
		case 8156697:
			//com.GameInterface.UtilsBase.PrintChatText("Buff2 Updated");
			this.m_EF.counter.text = 7;
			this.m_EF.border._visible = true;
			break;
	}

}

function SlotBuffAdded(buffId:Number)
{
	switch(buffId)
	{
		case 6497060:
			//com.GameInterface.UtilsBase.PrintChatText("Buff1 Added");
			this.m_EF.counter.text = this.m_ClientCharacter.m_BuffList[buffId].m_Count;
			this.m_EF.border._visible = false;
			break;
		
		case 8156697:
			//com.GameInterface.UtilsBase.PrintChatText("Buff2 Added");
			this.m_EF.counter.text = 7;
			this.m_EF.border._visible = true;
			break;
	}

}

function SlotBuffRemoved(buffId:Number)
{
	switch(buffId)
	{
		case 6497060:
			//com.GameInterface.UtilsBase.PrintChatText("Buff1 Removed");
			break;
		
		case 8156697:
			this.m_EF.counter.text = 0;
			this.m_EF.border._visible = false;
			break;
	}

}

function IBuffAdded(buffId:Number)
{
	switch(buffId)
	{
		case 6307518:
			//com.GameInterface.UtilsBase.PrintChatText("EF Slotted");
			break;
	}

}

function IBuffChanged(buffId:Number)
{
	switch(buffId)
	{
		case 6307518:
			//com.GameInterface.UtilsBase.PrintChatText("EF Changed");
			break;
	}

}

function ResetEF() {
	for (var i:Number = 0 ; i < 8 ; i++) {
		//com.GameInterface.UtilsBase.PrintChatText("loop.");
		var Slot = com.GameInterface.SpellBase.GetPassiveAbility(i);
		var Passive = com.GameInterface.SpellBase.m_PassivesList[Slot];
		if (Passive.m_Name == "Elemental Force" || Passive.m_Name == "Force élémentaire" || Passive.m_Name == "Elementargewalt") {
			//com.GameInterface.UtilsBase.PrintChatText("EF Reset");
			com.GameInterface.Chat.SignalShowFIFOMessage.Emit("Elemental Force Reset", 0);
			com.GameInterface.SpellBase.UnequipPassiveAbility(i);
			com.GameInterface.SpellBase.EquipPassiveAbility(i, 6307518);
			m_EF.border._visible = false;
			m_EF.counter.text = 0;
		}
	}
}

//Functions for Viper's Bar

// The compass check function.
function PositionIcon() {
	m_CompassCheckTimerCount++;
	if (m_CompassCheckTimerCount > m_CompassCheckTimerLimit) clearInterval(m_CompassCheckTimerID);
	if (_root.compass._x > 0) {
		clearInterval(m_CompassCheckTimerID);
		m_Icon._x = _root.compass._x - 128;
		m_Icon._y = _root.compass._y + 0;
	}
}

// The function that checks if VTIO is actually loaded and if it is sends the add-on information defined earlier.
// This function will also get called if VTIO loads after your add-on. Make sure not to remove the check for seeing if the value is actually true.
function SlotCheckVTIOIsLoaded() {
	if (DistributedValue.GetDValue("VTIO_IsLoaded")) DistributedValue.SetDValue("VTIO_RegisterAddon", VTIOAddonInfo);
}

/*
function GetBuffData(buffId) {
	for (var _local2 in m_Character.m_BuffList) {
		var _local1 = com.GameInterface.Game.BuffData(m_Character.m_BuffList[_local2]);
		if ((_local1 != null) && (_local1.m_BuffId == buffId)) {
			return(_local1);
		}
	}
	return(null);
}
*/

function SaveSettings()
{
	var a:Archive = new Archive();
	a.AddEntry("x", m_EF._x);
	a.AddEntry("y", m_EF._y);
	a.AddEntry("xscale", m_EF._xscale);
	//com.GameInterface.UtilsBase.PrintChatText("Settings Saved");
	return a;
}

function LoadSettings()
{
	//com.GameInterface.UtilsBase.PrintChatText("Loading Settings");
	m_EF._x = config.FindEntry("x");
	m_EF._y = config.FindEntry("y");
	m_EF._xscale = config.FindEntry("xscale");
}


function onUnload() {}
function OnModuleDeactivated()
{
	/*var a:Archive = new Archive();
	a.AddEntry("x", m_EF._x);
	a.AddEntry("y", m_EF._y);
	a.AddEntry("xsacle", m_EF._xscale);
	
	return a;
	*/
	return SaveSettings();
}
