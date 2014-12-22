import com.GameInterface.Game.Character;
import com.Utils.Archive;
import com.Utils.Signal;
import com.GameInterface.DistributedValue;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipInterface;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.Spell;
import com.GameInterface.SpellData;

var ModVersion:String = "2.0";

var m_EF:MovieClip;

var m_ClientCharacter:Character;

var ShowEFCounter:Boolean = false;

//Crap for Viper's Bar

var m_Icon:MovieClip;
var m_VTIOIsLoadedMonitor:DistributedValue;

var m_CompassCheckTimerID:Number;
var m_CompassCheckTimerLimit:Number = 256;
var m_CompassCheckTimerCount:Number = 0;

var VTIOAddonInfo:String = "EF Counter|Belladawna|"+ModVersion+"||_root.elementalforcecounter\\elementalforcecounter.m_Icon";

function onLoad()
{
	
	VTIOHook();
	
}

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
			
	//Check for DV set by Val's mod
	dvMPREnabled = DistributedValue.Create("MPRActivated");
	if (DistributedValue.GetDValue("MPRActivated") == undefined)
	{
		DistributedValue.SetDValue("MPRActivated", false);
	}
	
	m_EF.border._visible = false;
	m_EF.counter.text = 0;
	
	var isMP = 0

	m_EF.onMousePress = function (buttonID) {
		//com.GameInterface.UtilsBase.PrintChatText(buttonID);
		if (Key.isDown(16)) {
			this.startDrag();
		} else if (buttonID == 2) {
			//Right Mouse Button
		} else {
			var isInCombat:Boolean = m_ClientCharacter.IsInCombat();
			if (com.GameInterface.SpellBase.IsPassiveEquipped(6307518) && !isInCombat && DistributedValue.GetDValue("MPRActivated") == false) {
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
	
	for ( var i:Number = 0; i < 7; i++)
	{
		var passiveID:Number = Spell.GetPassiveAbility(i);
		if (passiveID == 6307518)
		{
			//com.GameInterface.UtilsBase.PrintChatText("EF Found");
			ShowEFCounter = true;
		}
	}
	
	m_EF._visible = ShowEFCounter;
	
	m_ClientCharacter = Character.GetClientCharacter();
	
	m_ClientCharacter.SignalBuffAdded.Connect(SlotBuffAdded, this);
	m_ClientCharacter.SignalBuffUpdated.Connect(SlotBuffChanged, this);
	m_ClientCharacter.SignalBuffRemoved.Connect(SlotBuffRemoved, this);
	
	Spell.SignalPassiveRemoved.Connect( SlotPassiveRemoved, this );
	Spell.SignalPassiveAdded.Connect( SlotPassiveAdded, this  );

	//ViTOHook();
	
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

function SlotPassiveAdded( itemPos:Number) : Void
{
	var passiveID:Number = Spell.GetPassiveAbility(itemPos);
	//var passiveData:SpellData = Spell.m_PassivesList[passiveID];
	//com.GameInterface.Chat.SignalShowFIFOMessage.Emit("itemPos: " + itemPos);
	//com.GameInterface.Chat.SignalShowFIFOMessage.Emit("passiveID: " + passiveID);

	switch(passiveID)
		{
			case 6307518:
				//com.GameInterface.Chat.SignalShowFIFOMessage.Emit("EF Added");
				ShowEFCounter = true;
				m_EF._visible = ShowEFCounter;
				break
		}

}

function SlotPassiveRemoved( itemPos:Number) : Void
{
	var passiveID:Number = Spell.GetPassiveAbility(itemPos);
	//var passiveData:SpellData = Spell.m_PassivesList[passiveID];
	//com.GameInterface.Chat.SignalShowFIFOMessage.Emit("itemPos: " + itemPos);
	//com.GameInterface.Chat.SignalShowFIFOMessage.Emit("passiveID: " + passiveID);

	switch(passiveID)
		{
			case 6307518:
				//com.GameInterface.Chat.SignalShowFIFOMessage.Emit("EF Removed");
				ShowEFCounter = false;
				m_EF._visible = ShowEFCounter;
				break
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
	//com.GameInterface.UtilsBase.PrintChatText("Place EF Icon");
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

function SaveSettings()
{
	var a:Archive = new Archive();
	a.AddEntry("x", m_EF._x);
	a.AddEntry("y", m_EF._y);
	a.AddEntry("xscale", m_EF._xscale);
	//com.GameInterface.UtilsBase.PrintChatText("Settings Saved");
	return a;
}

function OnModuleDeactivated()
{
	return SaveSettings();
}

function VTIOHook()
{
	
	//Crap for Viper's Bar
	
	// Setting up the VTIO loaded monitor.
	m_VTIOIsLoadedMonitor = DistributedValue.Create("VTIO_IsLoaded");
	m_VTIOIsLoadedMonitor.SignalChanged.Connect(SlotCheckVTIOIsLoaded, this);

	// Setting up your icon.
	m_Icon = attachMovie("Icon", "m_Icon", getNextHighestDepth());
	m_Icon._width = 18;
	m_Icon._height = 18;
	m_Icon.onMousePress = function(buttonID) {
		if (buttonID == 1) {
			// Do left mouse button stuff.  Hide/Unhide window
			ShowEFCounter = !ShowEFCounter;
			m_EF._visible = ShowEFCounter;
		} else if (buttonID == 2) {
			// Do right mouse button stuff.
		}
	}

	m_Icon.onRollOver = function() {
		if (m_Tooltip != undefined) m_Tooltip.Close();
        var tooltipData:TooltipData = new TooltipData();
		tooltipData.AddAttribute("", "<font face='_StandardFont' size='13' color='#FF8000'><b>Elemental Force Counter "+ModVersion+"</b></font>");
        tooltipData.AddAttributeSplitter();
        tooltipData.AddAttribute("", "");
        tooltipData.AddAttribute("", "<font face='_StandardFont' size='12' color='#FFFFFF'>Left Click to show/hide.\n\nDisable click to reset with Val's Master Planner Reminder.</font>");
        tooltipData.m_Padding = 4;
        tooltipData.m_MaxWidth = 210;
		m_Tooltip = TooltipManager.GetInstance().ShowTooltip(undefined, TooltipInterface.e_OrientationVertical, 0, tooltipData);
	}
	m_Icon.onRollOut = function() {
		if (m_Tooltip != undefined)	m_Tooltip.Close();
	}
	
	// Start the compass check.
	//m_CompassCheckTimerID = setInterval(PositionIcon, 100);
	//PositionIcon();

	// Check if VTIO is loaded (if it loaded before this add-on was).
	SlotCheckVTIOIsLoaded();
		
}