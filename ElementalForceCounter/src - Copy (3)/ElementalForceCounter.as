import com.GameInterface.Game.Character;
import com.Utils.Archive;
import com.Utils.Signal;

var m_EF:MovieClip;

var m_ClientCharacter:Character;

function onLoad() {}

function OnModuleActivated(config:Archive)
{
	m_EF.border._visible = false;
	m_EF.counter.text = 0;
	
	m_EF.onPress = function () {
		if (Key.isDown(16)) {
			this.startDrag();
		} else {
			var isInCombat:Boolean = m_ClientCharacter.IsInCombat();
			if (com.GameInterface.SpellBase.IsPassiveEquipped(6307518) && !isInCombat) {
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
			var _EFSize = m_EF._xscale;
			_EFSize = _EFSize + (3 * d);
			if (_EFSize < 50) {
  		      	_EFSize = 50;
			}
   		    if (_EFSize > 400) {
            	_EFSize = 400;
            }
        m_EF._xscale = (m_EF._yscale = _EFSize);
		SaveSettings();
		}
	}
	
	if (config.FindEntry("x"))
	{
		m_EF._x = config.FindEntry("x");
		m_EF._y = config.FindEntry("y");
		m_EF._xscale = config.FindEntry("xscale");
	}
	else
	{
		m_EF._x = 400;
		m_EF._y = 50;
	}
	
	
	m_ClientCharacter = Character.GetClientCharacter();
	
	m_ClientCharacter.SignalBuffAdded.Connect(SlotBuffAdded, this);
	m_ClientCharacter.SignalBuffUpdated.Connect(SlotBuffChanged, this);
	m_ClientCharacter.SignalBuffRemoved.Connect(SlotBuffRemoved, this);
	
	m_ClientCharacter.SignalInvisibleBuffAdded.Connect(IBuffAdded, this);
	m_ClientCharacter.SignalInvisibleBuffUpdated.Connect(IBuffChanged, this);
	
	
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
			com.GameInterface.UtilsBase.PrintChatText("EF Slotted");
			break;
	}

}

function IBuffChanged(buffId:Number)
{
	switch(buffId)
	{
		case 6307518:
			com.GameInterface.UtilsBase.PrintChatText("EF Changed");
			break;
	}

}

function ResetEF() {
	for (var i:Number = 0 ; i < 8 ; i++) {
		//com.GameInterface.UtilsBase.PrintChatText("loop.");
		var aSlot = com.GameInterface.SpellBase.GetPassiveAbility(i);
		var aPassive = com.GameInterface.SpellBase.m_PassivesList[aSlot];
		if (aPassive.m_Name == "Elemental Force") {
			//com.GameInterface.UtilsBase.PrintChatText("EF Reset");
			com.GameInterface.Chat.SignalShowFIFOMessage.Emit("Elemental Force Reset", 0);
			com.GameInterface.SpellBase.UnequipPassiveAbility(i);
			com.GameInterface.SpellBase.EquipPassiveAbility(i, 6307518);
			m_EF.border._visible = false;
			m_EF.counter.text = 0;
		}
	}
}

function GetBuffData(buffId) {
	for (var _local2 in m_Character.m_BuffList) {
		var _local1 = com.GameInterface.Game.BuffData(m_Character.m_BuffList[_local2]);
		if ((_local1 != null) && (_local1.m_BuffId == buffId)) {
			return(_local1);
		}
	}
	return(null);
}

function SaveSettings()
{
	var a:Archive = new com.Utils.Archive();
	a.AddEntry("x", m_EF._x);
	a.AddEntry("y", m_EF._y);
	a.AddEntry("xsacle", m_EF._xscale);
}


function onUnload() {}
function OnModuleDeactivated()
{
	var a:Archive = new Archive();
	a.AddEntry("x", m_EF._x);
	a.AddEntry("y", m_EF._y);
	a.AddEntry("xsacle", m_EF._xscale);
	
	return a;
}
