# Copy to Server @ c:\DRSMonitoring
#Create working Dir @ C:\MonitoringFiles
# new Key HKLM:\SOFTWARE\DRSmonitoring
#   Property = Monitoring Value = 1 # 1 = on 0 = off
# Create Monitor Deploy tool
#    Make it generic to be reused in future for other tools
# Create Audit tool
#  Is the config installed? Are the appropriate paths there? Is the registry key there?  What was it's value?
#  Produce an HTML Report
# Create Custom Type for report object
#   Add a default format to the object type

#1. create config.xml from csv - done
#2. Deploy config file and registry Setting - Script
#    - Deploy Key
#    - Deploy Config.xml
#3. Audit progress on Deployment
#   - Audit Config.xml Function
#   - Audit Deployment Function
#      - Does the Key exist?
#      - is it set correctly?
#      - Key Value
#      - Audit Date
#      - Computername
#      - is the config file deployed?
#      - Is the config file current?
#      - Able to update config.xml if required
#      - custom Type
#      - Default Formatting