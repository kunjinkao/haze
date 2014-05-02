from datetime import date, timedelta
import time
from OSC import OSCClient, OSCMessage 

 
sc_client = OSCClient()
p5_client = OSCClient()

sc_client.connect( ("localhost", 57120) )

current_date = date(2010, 1, 1)


def date_to_str(date):
    return "%s-%s-%s" % (date.year, date.month, date.day)

if __name__ == '__main__':
    while True:
        date_str = date_to_str(current_date)
        print date_str
        sc_client.send( OSCMessage("/date", date_str ) )
        current_date += timedelta(days=1)
        time.sleep(5)
        if(current_date.year>=2014):
            break
        
        
    