//THIS NODE IS AN EXEPTION TO THE MASTER RESET PACKET
//Self explainatory
integer Price;
default
{
    on_rez(integer duh)
    {
        llResetScript();
    }
    state_entry()
    {
        //Request money permissions
        llRequestPermissions(llGetOwner(),PERMISSION_DEBIT);
    }
    link_message(integer link, integer num, string msg, key k)
    {
        //Is it a Money Manager Node?
        if(num == 57)
        {
            //Is it a set price event?
            if(k == "SETPRICE")
            {
                //Do as the master says =P
                Price = (integer)msg;
                llSetPayPrice(PAY_HIDE,[Price,PAY_HIDE,PAY_HIDE,PAY_HIDE]);
            }
            //Do we need to refund?
            else if(k == "REFUND")
            {
                //Do so then
                list lDecode = llParseString2List(msg,["--"],[]);
                llGiveMoney(llList2Key(lDecode,0),llList2Integer(lDecode,1));
                lDecode=[];
            }
        }
    }
    money(key who, integer ammount)
    {
        //Check to ensure the prices are the same
        if(Price == ammount)
        {
            //Send the server our message
            llMessageLinked(LINK_SET,58,(string)who+"--"+llKey2Name(who),"DOPURCHASE");
        }
        else
        {
            //Refund them(moron)
            llGiveMoney(who, ammount);
        }
    }
}
