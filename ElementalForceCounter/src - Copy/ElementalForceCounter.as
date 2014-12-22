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
			//com.GameInterface.UtilsBase.PrintChatText("Looking for EF.");
			if (!isInCombat) {
				//com.GameInterface.UtilsBase.PrintChatText("Not in combat");
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
			} else {
				//com.GameInterface.UtilsBase.PrintChatText("Can't reset EF in combat");
				com.GameInterface.Chat.SignalShowFIFOMessage.Emit("Can't Reset Elemental Force in Combat", 0);
			}
		}
	};

	m_EF.onRelease = m_EF.onReleaseOutside = function()
	{
		this.stopDrag();
	}
	
	if (config.FindEntry("x"))
	{
		m_EF._x = config.FindEntry("x");
		m_EF._y = config.FindEntry("y");
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


function onUnload() {}
function OnModuleDeactivated()
{
	var a:Archive = new Archive();
	a.AddEntry("x", m_EF._x);
	a.AddEntry("y", m_EF._y);
	
	return a;
}
