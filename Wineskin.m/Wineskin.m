//  Wineskin.m
//  Copyright 2012 by The Wineskin Project and doh123@doh123.com All rights reserved.
//  Licensed for use under the LGPL <http://www.gnu.org/licenses/lgpl-2.1.txt>

#import <Cocoa/Cocoa.h>
#include <sys/stat.h>

@interface Wineskin : NSObject
{
	NSString *contentsFold;					//Contents folder in the wrapper
	NSString *frameworksFold;				//Frameworks folder in the wrapper
	NSString *appNameWithPath;				//full path to and including the app name
	NSString *lockfile;						//lockfile being used to know if the app is already in use
    NSString *tmpFolder;                    //where tmp files can be made and used to be specific to just this wrapper
	NSString *engineVersion;				//engine being used
	NSString *wineserverPIDFile;			//pid file holding wineserver pid of current/last run
	NSString *displayNumberFile;			//pid file holding display number of current/last run
	NSString *infoPlistFile;				//the Info.plist file in the wrapper
	NSString *winePrefix;					//the $WINEPREFIX
	NSString *theDisplayNumber;				//the Display Number to use
	NSString *x11PrefFileName;				//the name of the X11 plist file
	NSString *wineRunLocation;				//path to exe for wine
	NSString *wineRunFile;					//exe file name for wine to run
	NSString *programFlags;					//command line argments to windows exectuable
    NSString *wineLogFile;                  //location of wine log file
    NSString *wineTempLogFile;              //location of wine temp log file
    NSString *x11LogFile;                   //location of x11 log file
    NSString *x11PListFile;                 //location of x11 plist
	BOOL runWithStartExe;					//wether start.exe is being used
	BOOL fullScreenOption;					//wether running fullscreen or rootless (RandR is rootless)
	BOOL useRandR;							//if "Autoamatic" is set in Wineskin.app
	BOOL useGamma;							//wether or not gamma correction will be checked for
	BOOL forceWrapperQuartzWM;				//YES if forced to use wrapper quartz-wm and not newest version on the system
	BOOL useXQuartz;						//YES if using System XQuartz instead of WineskinX11
	NSString *vdResolution; 				//virtual desktop resolution to be used for rootless or fullscreen
	NSString *gammaCorrection;				//added in gamma correction
	NSString *fullScreenResolutionBitDepth;	//fullscreen bit depth for X server
	NSString *currentResolution; 			//the resolution that was running when the wrapper was started
	int sleepNumber;						//fullscreen resolution switch pause number in seconds
	NSString *wineserverPIDToCheck;			//wineserver PID of last run
	NSString *wineServerPID; 				//wineserver PID of current run
	NSString *wrapperBundlePID;				//PID of running wrapper bundle
	NSString *wineskinX11PID;				//PID of running WineskinX11 exectuable (not used except for shutdown, only use wrapper bundle for checks)
	NSString *xQuartzX11BinPID;				//PID of running XQuartz X11.bin (only needed for Override->Fullscreen)
	NSString *xQuartzBundlePID;				//PID of running XQuartz bundle (only needed for Override->Fullscreen)
	NSMutableArray *filesToRun;				//list of files passed in to open
	BOOL debugEnabled;						//set if debug mode is being run, to make logs
	BOOL cexeRun;							//set if runnin from a custom exe launcher
	BOOL nonStandardRun;					//set if a special wine run
	BOOL openingFiles;						//set if we are opening files instead of a program
	BOOL isIce;								//YES if ICE engine being used
	NSString *wssCommand;					//should be argv[1], if a special command
	NSArray *winetricksCommands;			//should be argv[2]+ if wssCommand is WSS-winetricks
	NSString *programNameAndPath;			//directly from the info.plist
	NSString *uLimitNumber;					//read from "max open files" in Info.plist
	NSString *wineDebugLineFromPlist;		//read from "WINEDEBUG=" in Info.plist
	NSString *randrXres;					//holds X res for keyboard shortcut to toggle back to fullscreen mode
	NSString *randrYres;					//holds Y res for keyboard shortcut to toggle back to fullscreen mode
	BOOL killWineskin;						//sets to true if opening files and wineserver was already running, kills extra wineskin
	NSString *cliCustomCommands;			//from CLI Variables entry in info.plist
	NSString *dyldFallBackLibraryPath;		//the path for DYLD_FALLBACK_LIBRARY_PATH
}
//the main running of the program...
- (void)mainRun:(NSArray *)argv;

//used to change the gamma setting since Xquartz cannot yet
- (void)setGamma:(NSString *)inputValue;

//used to change the global screen resolution for overriding randr
- (void)setResolution:(NSString *)reso;

//returns the current screen resolution
- (NSString *)getResolution;

//use to run a system() call but have the text returned as string
- (NSString *)systemCommand:(NSString *)command;

//Makes an Array with a list of PIDs that match the process name
- (NSArray *)makePIDArray:(NSString *)processToLookFor;

//sets the drive_c/user/Wineskin folder correctly for a run
- (void)setUserFolders:(BOOL)doSymlinks;

//Makes sure the current user owns the winepeefix, or Wine will not run
- (void)fixWinePrefixForCurrentUser;

//Tries to get the GPU info and enter it in the Wine Registry, use before starting Wine
- (void)tryToUseGPUInfo;

//remove GPU info from Registry
- (void)removeGPUInfo;

//fixes whatever libraries in Frameworks needs to be set before launching X or Wine
- (void)fixFrameworksLibraries;

//returns the correct line needed for startX11 to get the right quartz-wm started
- (NSString *)setWindowManager;

//starts up WineskinX11
- (void)startX11;

//starts up XQuartz
- (void)startXQuartz;

//bring the app to the front most
- (void)bringToFront:(NSString *)thePid;

//installs ICE files
- (void)installEngine;

//Changes VD Desktop user.reg entries to a given virtual desktop
- (void)setToVirtualDesktop:(NSString *)resolution named:(NSString *)desktopName;

//Changes VD Desktop user.reg entires to not have a virtual desktop
- (void)setToNoVirtualDesktop;

//reads a file and passes back contents as an array of strings
- (NSArray *)readFileToStringArray:(NSString *)theFile;

//writes an array to a normal text file, each entry on a line.
- (void)writeStringArray:(NSArray *)theArray toFile:(NSString *)theFile;

//returns true if running PID has the specified name
- (BOOL)isPID:(NSString *)pid named:(NSString *)name;

//start wine, return wineserver PID;
- (NSString *)startWine;

//background monitoring while Wine is running
- (void)sleepAndMonitor;

//run when shutting down
- (void)cleanUpAndShutDown;

//test display string in pop up
- (void)ds:(NSString *)input;
@end

@implementation Wineskin
- (void)mainRun:(NSArray *)argv
{
    NSFileManager *fm = [NSFileManager defaultManager];
	// TODO need to add option to make wrapper run in AppSupport (shadowcopy) so that no files will ever be written in the app
	// TODO need to make all the temp files inside the wrapper run correctly using BundleID and in /tmp.  If they don't exist, assume everything is fine.
	// TODO add blocks to sections that need them for variables to free up memory.
	filesToRun = [[NSMutableArray alloc] init];
	runWithStartExe = NO;
	fullScreenOption = NO;
	useRandR = NO;
	useGamma = YES;
	gammaCorrection = @"default";
	wineserverPIDToCheck = @"-9";
	debugEnabled = NO;
	cexeRun = NO;
	nonStandardRun = NO;
	openingFiles = NO;
	wssCommand = @"nothing";
	randrXres = @"0";
	randrYres = @"0";
	killWineskin = NO;
	isIce = NO;
	if ([argv count]>0) wssCommand = [argv objectAtIndex:0];
	if ([wssCommand isEqualToString:@"CustomEXE"]) cexeRun = YES;
	//if wssCommand is WSS-InstallICE, then just run ICE install and quit!
	contentsFold=[[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] bundlePath]] stringByReplacingOccurrencesOfString:@"/Frameworks/bin" withString:@""];
	frameworksFold=[NSString stringWithFormat:@"%@/Frameworks",contentsFold];
	appNameWithPath=[[NSString stringWithFormat:@"%@",contentsFold] stringByReplacingOccurrencesOfString:@"/Contents" withString:@""];
	infoPlistFile = [NSString stringWithFormat:@"%@/Info.plist",contentsFold];
	winePrefix=[NSString stringWithFormat:@"%@/Resources",contentsFold];
    tmpFolder=[NSString stringWithFormat:@"/tmp/%@",[appNameWithPath stringByReplacingOccurrencesOfString:@"/" withString:@"xWSx"]];
    [fm createDirectoryAtPath:tmpFolder withIntermediateDirectories:YES attributes:nil error:nil];
    displayNumberFile = [NSString stringWithFormat:@"%@/currentuseddisplay",tmpFolder];
    wineserverPIDFile = [NSString stringWithFormat:@"%@/wineserverpidfile",tmpFolder];
    
    
    
    
	lockfile=[NSString stringWithFormat:@"%@/lockfile",tmpFolder];
    wineLogFile = [NSString stringWithFormat:@"%@/Logs/LastRunWine.log",winePrefix];
    wineTempLogFile = [NSString stringWithFormat:@"%@/LastRunWineTemp.log",tmpFolder];
    x11LogFile = [NSString stringWithFormat:@"%@/Logs/LastRunX11.log",winePrefix];
	//exit if the lock file exists, another user is running this wrapper currently
    BOOL lockFileAlreadyExisted = NO;
	if ([fm fileExistsAtPath:lockfile])
	{
		//read in lock file to get user name of who locked it, if same user name ignore
		if (![[[self readFileToStringArray:lockfile] objectAtIndex:0] isEqualToString:NSUserName()])
		{
			CFUserNotificationDisplayNotice(0, 0, NULL, NULL, NULL, CFSTR("ERROR"), CFSTR("Another user on this system is currently using this application\n\nThey must exit the application before you can use it."), NULL);
			return;
		}
        lockFileAlreadyExisted = YES;
	}
    else
    {
        //create lockfile that we are already in use
        [self writeStringArray:[NSArray arrayWithObject:NSUserName()] toFile:lockfile];
    }
	[self installEngine];
	if ([wssCommand isEqualToString:@"WSS-InstallICE"])
    {
        //delete the lockfile
        [fm removeItemAtPath:tmpFolder error:nil];
        //just called for ICE install, dont run.
        return;
    }
    if ([fm fileExistsAtPath:wineserverPIDFile])
        wineserverPIDToCheck = [[self readFileToStringArray:wineserverPIDFile] objectAtIndex:0];
	NSLog(@"Starting up...");
	NSLog(@"reading all configuration information...");
	//open Info.plist to read all needed info
	NSMutableDictionary *plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:infoPlistFile];
	NSDictionary *cexePlistDictionary;
	NSString *resolutionTemp = @"";
	//check to make sure CFBundleName is not WineskinWineskinDefault3345, if it is, change it to current wrapper name
	if ([[plistDictionary valueForKey:@"CFBundleName"] isEqualToString:@"WineskinWineskinDefault3345"])
	{
		NSString *tempWrapperName = [[appNameWithPath substringFromIndex:[appNameWithPath rangeOfString:@"/" options:NSBackwardsSearch].location+1] stringByReplacingOccurrencesOfString:@".app" withString:@""];
		[plistDictionary setValue:tempWrapperName forKey:@"CFBundleName"];
		[plistDictionary writeToFile:infoPlistFile atomically:YES];
	}
    //Randomize the CFBundleID for every launch
	srand((unsigned)time(0));
	int bundleRandomInt1 = (int)(rand()%999999999);
	if (bundleRandomInt1<0){bundleRandomInt1=bundleRandomInt1*(-1);}
    int bundleRandomInt2 = (int)(rand()%999999999);
	if (bundleRandomInt2<0){bundleRandomInt2=bundleRandomInt2*(-1);}
    [plistDictionary setValue:[NSString stringWithFormat:@"%@%@.wineskin.prefs",[[NSNumber numberWithLong:bundleRandomInt1] stringValue],[[NSNumber numberWithLong:bundleRandomInt2] stringValue]] forKey:@"CFBundleIdentifier"];
    [plistDictionary writeToFile:infoPlistFile atomically:YES];
	//need to handle it different if its a cexe
	if (!cexeRun)
	{
		programNameAndPath = [plistDictionary valueForKey:@"Program Name and Path"];
		programFlags = [plistDictionary valueForKey:@"Program Flags"];
		fullScreenOption = [[plistDictionary valueForKey:@"Fullscreen"] intValue];
		resolutionTemp = [plistDictionary valueForKey:@"Resolution"];
		runWithStartExe = [[plistDictionary valueForKey:@"use start.exe"] intValue];
		useRandR = [[plistDictionary valueForKey:@"Use RandR"] intValue];
	}
	else
	{
		cexePlistDictionary = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/Contents/Info.plist.cexe",appNameWithPath,[argv objectAtIndex:1]]];
		programNameAndPath = [cexePlistDictionary valueForKey:@"Program Name and Path"];
		programFlags = [cexePlistDictionary valueForKey:@"Program Flags"];
		fullScreenOption = [[cexePlistDictionary valueForKey:@"Fullscreen"] intValue];
		resolutionTemp = [cexePlistDictionary valueForKey:@"Resolution"];
		runWithStartExe = [[cexePlistDictionary valueForKey:@"use start.exe"] intValue];
		useGamma = [[cexePlistDictionary valueForKey:@"Use Gamma"] intValue];
		useRandR = [[cexePlistDictionary valueForKey:@"Use RandR"] intValue];
	}
	debugEnabled = [[plistDictionary valueForKey:@"Debug Mode"] intValue];
	forceWrapperQuartzWM = [[plistDictionary valueForKey:@"force wrapper quartz-wm"] intValue];
	useXQuartz = [[plistDictionary valueForKey:@"Use XQuartz"] intValue];
	//set correct dyldFallBackLibraryPath
	if (useXQuartz)
		dyldFallBackLibraryPath=[NSString stringWithFormat:@"/opt/X11/lib:/opt/local/lib:%@:%@/wswine.bundle/lib:/usr/lib:/usr/libexec:/usr/lib/system:/usr/X11/lib:/usr/X11R6/lib",frameworksFold,frameworksFold];
	else
		dyldFallBackLibraryPath=[NSString stringWithFormat:@"%@:%@/wswine.bundle/lib:/usr/lib:/usr/libexec:/usr/lib/system:/opt/X11/lib:/opt/local/lib:/usr/X11/lib:/usr/X11R6/lib",frameworksFold,frameworksFold];
	//gammaCorrection = [NSString stringWithFormat:@"%@",[plistDictionary valueForKey:@"Gamma Correction"]];
    gammaCorrection = [plistDictionary valueForKey:@"Gamma Correction"];
	x11PrefFileName = [plistDictionary valueForKey:@"CFBundleIdentifier"];
    x11PListFile = [NSString stringWithFormat:@"%@/Library/Preferences/%@.plist",NSHomeDirectory(),x11PrefFileName];
    uLimitNumber = @"";
    if ([[plistDictionary valueForKey:@"set max files"] intValue])
        uLimitNumber=@"launchctl limit maxfiles 10240 10240;ulimit -n 10240 > /dev/null 2>&1;";
	wineDebugLineFromPlist = [plistDictionary valueForKey:@"WINEDEBUG="];
	//if any program flags, need to add a space to the front of them
	if (!([programFlags isEqualToString:@""]))
		programFlags = [NSString stringWithFormat:@" %@",programFlags];
	//resolutionTemp needs to be stripped for resolution info, bit depth, and switch pause
	//vdreso
	vdResolution = [NSString stringWithFormat:@"%@",resolutionTemp];
	vdResolution = [vdResolution substringToIndex:[vdResolution rangeOfString:@"x" options:NSBackwardsSearch].location];
	//bitdepth
	fullScreenResolutionBitDepth = [NSString stringWithFormat:@"%@",resolutionTemp];
	fullScreenResolutionBitDepth = [fullScreenResolutionBitDepth stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@x",vdResolution] withString:@""];
	fullScreenResolutionBitDepth = [fullScreenResolutionBitDepth substringToIndex:[fullScreenResolutionBitDepth rangeOfString:@"sleep"].location];
	//sleep number
	NSString *sleepNumberTemp = [NSString stringWithFormat:@"%@",resolutionTemp];
	sleepNumberTemp = [sleepNumberTemp stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@x%@sleep",vdResolution,fullScreenResolutionBitDepth] withString:@""];
	sleepNumber = [sleepNumberTemp intValue];
	//make sure vdReso has a space, not an x
	vdResolution = [vdResolution stringByReplacingOccurrencesOfString:@"x" withString:@" "];
	currentResolution = [self getResolution];
	if ([vdResolution isEqualToString:@"Current Resolution"])
		vdResolution = [NSString stringWithFormat:@"%@",currentResolution];
	// get cliCustomCommands
	cliCustomCommands = [plistDictionary valueForKey:@"CLI Custom Commands"];
	// strip off trailing ; on cliCustomCommands if it exists
	if (!([cliCustomCommands hasSuffix:@";"]) && ([cliCustomCommands length] > 0))
		cliCustomCommands = [NSString stringWithFormat:@"%@;",cliCustomCommands];
	//******* fix all data correctly
	//list of possile options
	//WSS-installer {path/file}	- Installer is calling the program
	//WSS-winecfg 				- need to run winecfg
	//WSS-cmd					- need to run cmd
	//WSS-regedit 				- need to run regedit
	//WSS-taskmgr 				- need to run taskmgr
	//WSS-uninstall				- run uninstaller
	//WSS-wineprefixcreate		- need to run wineboot, refresh wrapper
	//WSS-wineprefixcreatenoregs- same as above, doesn't load default regs
	//WSS-wineboot				- run simple wineboot, no deletions or loading regs. mshtml=disabled
	//WSS-winetricks {command}	- winetricks is being run
	//debug 					- run in debug mode, keep logs
	//CustomEXE {appname}		- running a custom EXE with appname
	//starts with a"/" 			- will be 1+ path/filename to open
	//no command line args		- normal run
	if ([argv count] > 1)
	{
		winetricksCommands = [argv subarrayWithRange:NSMakeRange(1, [argv count]-1)];
	}
	if ([argv count] > 0)
	{
		if ([wssCommand hasPrefix:@"/"]) //if wssCommand starts with a / its file(s) passed in to open
		{
			for (NSString *item in argv)
				[filesToRun addObject:item];
			NSLog(@"files passed in to open, will open with associated app");
			openingFiles=YES;
		}
		else if ([wssCommand hasPrefix:@"WSS-"]) //if wssCommand starts with WSS- its a special command
		{
			debugEnabled=YES; //need logs in special commands
			useGamma=NO;
			if ([wssCommand isEqualToString:@"WSS-installer"]) //if its in the installer, need to know if normal windows are forced
			{
				if ([[plistDictionary valueForKey:@"force Installer to normal windows"] intValue] == 1)
				{
					fullScreenResolutionBitDepth = @"24";
					vdResolution = @"novd";
					fullScreenOption = NO;
					sleepNumber = 0;
				}
				programNameAndPath = [argv objectAtIndex:1]; // second argument full path and file name to run
				runWithStartExe = YES; //installer always uses start.exe
			}
			else //any WSS that isn't the installer
			{
				fullScreenResolutionBitDepth = @"24"; // all should force normal windows
				vdResolution = @"novd";
				fullScreenOption = NO;
				sleepNumber = 0;
				//should only use this line for winecfg cmd regedit and taskmgr, other 2 do nonstandard runs and wont use this line
				if ([wssCommand isEqualToString:@"WSS-regedit"])
					programNameAndPath = @"/windows/regedit.exe";
				else
				{
					if ([wssCommand isEqualToString:@"WSS-cmd"]) runWithStartExe=YES;
					programNameAndPath = [NSString stringWithFormat:@"/windows/system32/%@.exe",[wssCommand stringByReplacingOccurrencesOfString:@"WSS-" withString:@""]];
				}
				programFlags = @""; // just in case there were some flags... don't use on these.
				if ([wssCommand isEqualToString:@"WSS-wineboot"] || [wssCommand isEqualToString:@"WSS-wineprefixcreate"] || [wssCommand isEqualToString:@"WSS-wineprefixcreatenoregs"] || [wssCommand isEqualToString:@"WSS-winetricks"])
					nonStandardRun=YES; // handle Wine differently if its one of these 2
			}			
		}
		else if ([wssCommand isEqualToString:@"debug"]) //if wssCommand is debug, run in debug mode
		{
			debugEnabled=YES;
			NSLog(@"Debug Mode enabled");
		}
	}
	//if vdResolution is bigger than currentResolution, need to downsize it
	if (!([vdResolution isEqualToString:@"novd"]))
	{
		NSString *xRes = [vdResolution substringToIndex:[vdResolution rangeOfString:@" "].location];
		NSString *yRes = [vdResolution stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ ",xRes] withString:@""];
		NSString *xResMax = [currentResolution substringToIndex:[currentResolution rangeOfString:@" "].location];
		NSString *yResMax = [currentResolution stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ ",xResMax] withString:@""];
		if ([xRes intValue] > [xResMax intValue] || [yRes intValue] > [yResMax intValue])
			vdResolution = [NSString stringWithFormat:@"%@",currentResolution];
		
	}
	//fix wine run paths
	if (![programNameAndPath hasPrefix:@"/"])
		programNameAndPath = [NSString stringWithFormat:@"/%@",programNameAndPath];
	wineRunLocation = [programNameAndPath substringToIndex:[programNameAndPath rangeOfString:@"/" options:NSBackwardsSearch].location];
	wineRunFile = [programNameAndPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",wineRunLocation] withString:@""];
	//add path to drive C if its not an installer
	if (!([wssCommand isEqualToString:@"WSS-installer"]))
		wineRunLocation = [NSString stringWithFormat:@"%@/Resources/drive_c%@",contentsFold,wineRunLocation];
	
	//**********make sure that the set executable is found if normal run
	if (!openingFiles && !([wssCommand hasPrefix:@"WSS-"]) && !([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",wineRunLocation,wineRunFile]]))
	{
		//error, file doesn't exist, and its not a special command
		NSLog(@"Error! Set executable not found.  Wineskin.app running instead.");
		system([[NSString stringWithFormat:@"open \"%@/Wineskin.app\"",appNameWithPath] UTF8String]);
        [fm removeItemAtPath:tmpFolder error:nil];
		return;
	}
	//********** Wineskin Customizer start up script
	system([[NSString stringWithFormat:@"\"%@/WineskinStartupScript\"",winePrefix] UTF8String]);
	
	//**********set the display number
	srand((unsigned)time(0));
	int randomint = 5+(int)(rand()%9994);
	if (randomint<0){randomint=randomint*(-1);}
	theDisplayNumber = [NSString stringWithFormat:@":%@",[[NSNumber numberWithLong:randomint] stringValue]];

	//****** if CPUs Disabled, disable all but 1 CPU
	NSString *cpuCountInput;
	if ([[plistDictionary valueForKey:@"Disable CPUs"] intValue] == 1)
	{
		cpuCountInput = [self systemCommand:@"hwprefs cpu_count 2>/dev/null"];
		int i, cpuCount = [cpuCountInput intValue];
		for (i=2;i<=cpuCount;i++)
			[self systemCommand:[NSString stringWithFormat:@"hwprefs cpu_disable %d",i]];
	}
    
    if (lockFileAlreadyExisted)
    {
        killWineskin = YES;
        if(![self systemCommand:@"killall -0 WineskinX11 2>&1"])
        {
            NSLog(@"Lockfile ignored because no running WineskinX11 processes found");
            lockFileAlreadyExisted = NO;
            killWineskin = NO;
        }
    }
    if (!lockFileAlreadyExisted)
    {
        //**********start the X server
        if (useXQuartz)
        {
            NSLog(@"Starting up XQuartz");
            [self startXQuartz];
        }
        if (!useXQuartz)
        {
            NSLog(@"Starting up WineskinX11");
            [self startX11];
            if ([wrapperBundlePID isEqualToString:@"ERROR"])
            {
                [fm removeItemAtPath:tmpFolder error:nil];
                return;
            }
            NSLog(@"Wrapper Bundle running on PID %@",wrapperBundlePID);
            NSLog(@"WineskinX11 running on PID %@",wineskinX11PID);
        }
        //**********set user folders
        if ([[plistDictionary valueForKey:@"Symlinks In User Folder"] intValue] == 1)
        {
            NSLog(@"Fixing user folders in Drive C to current user");
            [self setUserFolders:YES];
        }
        else
            [self setUserFolders:NO];
        
        //********** fix wineprefix
        [self fixWinePrefixForCurrentUser];
        
        //********** If setting GPU info, do it
        if ([[plistDictionary valueForKey:@"Try To Use GPU Info"] intValue] == 1)
            [self tryToUseGPUInfo];
    }

    //**********start wine
	NSLog(@"Starting specified executable in Wine");
	wineServerPID = [self startWine];
	NSLog(@"Wineserver running on PID %@",wineServerPID);
	//********** exit if already running and just opening new file
	//if wineserver pid was already running in startWine and openFiles was true, then exit, we already have a Wineskin monitoring the wrapper
	if (killWineskin) return;
	
	//change fullscreen reso if needed
	if (fullScreenOption)
	{
		NSLog(@"Changing to requested starting resolution of %@...",vdResolution);
		[self setResolution:vdResolution];
	}
	
	//for xorg1.11.0+, log files are put in ~/Library/Logs.  Need to move to correct place if in Debug
	if (debugEnabled && !useXQuartz)
	{
        NSString *theBundleID = [[plistDictionary valueForKey:@"CFBundleIdentifier"] stringByReplacingOccurrencesOfString:@".wineskin.prefs" withString:@""];
		NSString *logName = [NSString stringWithFormat:@"%@/Library/Logs/X11/%@.Wineskin.p.log",NSHomeDirectory(),theBundleID];
		if ([fm fileExistsAtPath:logName])
		{
			[fm removeItemAtPath:x11LogFile error:nil];
			[fm copyItemAtPath:logName toPath:x11LogFile error:nil];
            [fm removeItemAtPath:logName error:nil];
		}
	}
    
    //********** Write system info to end X11 log file
    if (debugEnabled)
    {
        //use mini detail level so no personal information can be displayed
        [self systemCommand:[NSString stringWithFormat:@"system_profiler -detailLevel mini SPHardwareDataType SPDisplaysDataType >> \"%@\"",x11LogFile]];
    }
    
	//**********sleep and monitor in background while app is running
	NSLog(@"Sleeping and monitoring from the background while app runs...");
	[self sleepAndMonitor];
	
	//****** if CPUs Disabled, re-enable them
	if ([[plistDictionary valueForKey:@"Disable CPUs"] intValue] == 1)
	{
		int i, cpuCount = [cpuCountInput intValue];
		for (i=2;i<=cpuCount;i++)
			[self systemCommand:[NSString stringWithFormat:@"hwprefs cpu_enable %d",i]];
	}

	//********** Wineskin Customizer shut down script
	system([[NSString stringWithFormat:@"\"%@/WineskinShutdownScript\"",winePrefix] UTF8String]);
	
	//********** app finished, time to clean up and shut down
	NSLog(@"Application finished, cleaning up and shut down...\n");
    if ([[plistDictionary valueForKey:@"Try To Use GPU Info"] intValue] == 1) [self removeGPUInfo];
	[self cleanUpAndShutDown];
	NSLog(@"Finished!\n");
    [fm release];
    [plistDictionary release];
	return;
}

- (void)setGamma:(NSString *)inputValue
{
	if ([inputValue isEqualToString:@"default"])
	{
		CGDisplayRestoreColorSyncSettings();
		return;
	}
	double gamma = [inputValue doubleValue];
	CGDirectDisplayID activeDisplays[] = {0,0,0,0,0,0,0,0};
	CGDisplayCount activeDisplaysNum,totalDisplaysNum=8;
	CGDisplayErr error1 = CGGetActiveDisplayList(totalDisplaysNum,activeDisplays,&activeDisplaysNum);
	if (error1!=0) NSLog(@"setGamma function active display list failed! error = %d",error1);
	CGGammaValue gammaMin = 0.0;
	CGGammaValue gammaMax = 1.0;
	CGGammaValue gammaSettingsRED = gamma;
	CGGammaValue gammaSettingsGREEN = gamma;
	CGGammaValue gammaSettingsBLUE = gamma;
	CGSetDisplayTransferByFormula(*activeDisplays,gammaMin,gammaMax,gammaSettingsRED,gammaMin,gammaMax,gammaSettingsGREEN,gammaMin,gammaMax,gammaSettingsBLUE);
}

- (void)setResolution:(NSString *)reso
{
	NSString *xRes = [reso substringToIndex:[reso rangeOfString:@" "].location];
	NSString *yRes = [reso stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ ",xRes] withString:@""];
	//if XxY doesn't exist, we will ignore for now... in the future maybe add way to find the closest reso that is available.
	//change the resolution using Xrandr
	system([[NSString stringWithFormat:@"export PATH=\"%@/wswine.bundle/bin:%@/bin:$PATH:/opt/local/bin:/opt/local/sbin\";export DISPLAY=%@;export WINEPREFIX=\"%@\";cd \"%@/wswine.bundle/bin\";DYLD_FALLBACK_LIBRARY_PATH=\"%@\" xrandr -s %@x%@ > /dev/null 2>&1",frameworksFold,frameworksFold,theDisplayNumber,winePrefix,frameworksFold,dyldFallBackLibraryPath,xRes,yRes] UTF8String]);
}

- (NSString *)getResolution
{
	CGRect screenFrame = CGDisplayBounds(kCGDirectMainDisplay);
	CGSize screenSize  = screenFrame.size;
	return [NSString stringWithFormat:@"%.0f %.0f",screenSize.width,screenSize.height];
}

- (NSString *)systemCommand:(NSString *)command
{
	FILE *fp;
	char buff[512];
	NSString *returnString = @"";
	fp = popen([command cStringUsingEncoding:NSUTF8StringEncoding], "r");
	while (fgets( buff, sizeof buff, fp))
		returnString = [NSString stringWithFormat:@"%@%@",returnString,[NSString stringWithCString:buff encoding:NSUTF8StringEncoding]];
	pclose(fp);
	//cut out trailing new line
	if ([returnString hasSuffix:@"\n"])
		returnString = [returnString substringToIndex:[returnString rangeOfString:@"\n" options:NSBackwardsSearch].location];
	return returnString;
}

- (NSArray *)makePIDArray:(NSString *)processToLookFor
{
	NSString *resultString = [NSString stringWithFormat:@"00000\n%@",[self systemCommand:[NSString stringWithFormat:@"ps axc|awk \"{if (\\$5==\\\"%@\\\") print \\$1}\"",processToLookFor]]];
	return [resultString componentsSeparatedByString:@"\n"];
}

- (void)setUserFolders:(BOOL)doSymlinks
{
	NSFileManager *fm = [NSFileManager defaultManager];
	//get symlink locations
	NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:infoPlistFile];
	NSString *symlinkMyDocuments = [[plistDictionary valueForKey:@"Symlink My Documents"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	symlinkMyDocuments = [symlinkMyDocuments stringByReplacingOccurrencesOfString:@"$HOME" withString:NSHomeDirectory()];
	[fm createDirectoryAtPath:symlinkMyDocuments withIntermediateDirectories:YES attributes:nil error:nil];
	if (![fm fileExistsAtPath:symlinkMyDocuments] && [symlinkMyDocuments length] > 0)
	{
		NSString *tempOld = [NSString stringWithFormat:@"%@",symlinkMyDocuments];
		symlinkMyDocuments = [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
		NSLog(@"ERROR: \"%@\" requested to be linked to \"My Documents\", but folder does not exist and could not be created.  Using \"%@\" instead.",tempOld,symlinkMyDocuments);
	}
	NSString *symlinkDesktop = [[plistDictionary valueForKey:@"Symlink Desktop"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	symlinkDesktop = [symlinkDesktop stringByReplacingOccurrencesOfString:@"$HOME" withString:NSHomeDirectory()];
	[fm createDirectoryAtPath:symlinkDesktop withIntermediateDirectories:YES attributes:nil error:nil];
	if (![fm fileExistsAtPath:symlinkDesktop] && [symlinkDesktop length] > 0)
	{
		NSString *tempOld = [NSString stringWithFormat:@"%@",symlinkDesktop];
		symlinkDesktop = [NSString stringWithFormat:@"%@/Desktop",NSHomeDirectory()];
		NSLog(@"ERROR: \"%@\" requested to be linked to \"Desktop\", but folder does not exist and could not be created.  Using \"%@\" instead.",tempOld,symlinkDesktop);
	}
	NSString *symlinkMyVideos = [[plistDictionary valueForKey:@"Symlink My Videos"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	symlinkMyVideos = [symlinkMyVideos stringByReplacingOccurrencesOfString:@"$HOME" withString:NSHomeDirectory()];
	[fm createDirectoryAtPath:symlinkMyVideos withIntermediateDirectories:YES attributes:nil error:nil];
	if (![fm fileExistsAtPath:symlinkMyVideos] && [symlinkMyVideos length] > 0)
	{
		NSString *tempOld = [NSString stringWithFormat:@"%@",symlinkMyVideos];
		symlinkMyVideos = [NSString stringWithFormat:@"%@/Movies",NSHomeDirectory()];
		NSLog(@"ERROR: \"%@\" requested to be linked to \"My Videos\", but folder does not exist and could not be created.  Using \"%@\" instead.",tempOld,symlinkMyVideos);
	}
	NSString *symlinkMyMusic = [[plistDictionary valueForKey:@"Symlink My Music"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	symlinkMyMusic = [symlinkMyMusic stringByReplacingOccurrencesOfString:@"$HOME" withString:NSHomeDirectory()];
	[fm createDirectoryAtPath:symlinkMyMusic withIntermediateDirectories:YES attributes:nil error:nil];
	if (![fm fileExistsAtPath:symlinkMyMusic] && [symlinkMyMusic length] > 0)
	{
		NSString *tempOld = [NSString stringWithFormat:@"%@",symlinkMyMusic];
		symlinkMyMusic = [NSString stringWithFormat:@"%@/Music",NSHomeDirectory()];
		NSLog(@"ERROR: \"%@\" requested to be linked to \"My Music\", but folder does not exist and could not be created.  Using \"%@\" instead.",tempOld,symlinkMyMusic);
	}
	NSString *symlinkMyPictures = [[plistDictionary valueForKey:@"Symlink My Pictures"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	symlinkMyPictures = [symlinkMyPictures stringByReplacingOccurrencesOfString:@"$HOME" withString:NSHomeDirectory()];
	[fm createDirectoryAtPath:symlinkMyPictures withIntermediateDirectories:YES attributes:nil error:nil];
	if (![fm fileExistsAtPath:symlinkMyPictures] && [symlinkMyPictures length] > 0)
	{
		NSString *tempOld = [NSString stringWithFormat:@"%@",symlinkMyPictures];
		symlinkMyPictures = [NSString stringWithFormat:@"%@/Pictures",NSHomeDirectory()];
		NSLog(@"ERROR: \"%@\" requested to be linked to \"My Pictures\", but folder does not exist and could not be created.  Using \"%@\" instead.",tempOld,symlinkMyPictures);
	}
	//set the symlinks
	if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin",winePrefix]])
	{
		if (doSymlinks && ([symlinkMyDocuments length] > 0))
		{
			[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Documents",winePrefix] error:nil];
			[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Documents",winePrefix] withDestinationPath:symlinkMyDocuments error:nil];
			[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/users/Wineskin/My Documents\"",winePrefix]];
		}
		else
			[fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Documents",winePrefix] withIntermediateDirectories:NO attributes:nil error:nil];
		if (doSymlinks && ([symlinkDesktop length] > 0))
		{
			[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/Desktop",winePrefix] error:nil];
			[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/Desktop",winePrefix] withDestinationPath:symlinkDesktop error:nil];
			[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/users/Wineskin/Desktop\"",winePrefix]];
		}
		else
			[fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/Desktop",winePrefix] withIntermediateDirectories:NO attributes:nil error:nil];
		if (doSymlinks && ([symlinkMyVideos length] > 0))
		{
			[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Videos",winePrefix] error:nil];
			[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Videos",winePrefix] withDestinationPath:symlinkMyVideos error:nil];
			[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/users/Wineskin/My Videos\"",winePrefix]];
		}
		else
			[fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Videos",winePrefix] withIntermediateDirectories:NO attributes:nil error:nil];
		if (doSymlinks && ([symlinkMyMusic length] > 0))
		{
			[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Music",winePrefix] error:nil];
			[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Music",winePrefix] withDestinationPath:symlinkMyMusic error:nil];
			[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/users/Wineskin/My Music\"",winePrefix]];
		}
		else
			[fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Music",winePrefix] withIntermediateDirectories:NO attributes:nil error:nil];
		if (doSymlinks && ([symlinkMyPictures length] > 0))
		{
			[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Pictures",winePrefix] error:nil];
			[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Pictures",winePrefix] withDestinationPath:symlinkMyPictures error:nil];		
			[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/users/Wineskin/My Pictures\"",winePrefix]];
		}
		else
			[fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Pictures",winePrefix] withIntermediateDirectories:NO attributes:nil error:nil];
	}
	[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/users/%@",winePrefix,NSUserName()] withDestinationPath:@"Wineskin" error:nil];	
	[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/users/%@\"",winePrefix,NSUserName()]];
	[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/users/crossover",winePrefix] withDestinationPath:@"Wineskin" error:nil];
	[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/users/crossover\"",winePrefix]];
	[fm release];
}

- (void)fixWinePrefixForCurrentUser
{
	// changing owner just fails, need this to work for normal users without admin password on the fly.
	// Needed folders are set to 777, so just make a new resources folder and move items, should always work.
	// NSFileManager changing posix permissions still failing to work right, using chmod as a system command
	NSFileManager *fm = [NSFileManager defaultManager];
	//if owner and current user match, exit
	NSDictionary *checkThis = [fm attributesOfItemAtPath:winePrefix error:nil];
	if ([NSUserName() isEqualToString:[checkThis valueForKey:@"NSFileOwnerAccountName"]])
	{
		[fm release];
		return;
	}
	//make ResoTemp
	[fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/ResoTemp",contentsFold] withIntermediateDirectories:NO attributes:nil error:nil];
	//move everything from Resources to ResoTemp
	NSArray *tmpy = [fm contentsOfDirectoryAtPath:winePrefix error:nil];
	for (NSString *item in tmpy)
		[fm moveItemAtPath:[NSString stringWithFormat:@"%@/Resources/%@",contentsFold,item] toPath:[NSString stringWithFormat:@"%@/ResoTemp/%@",contentsFold,item] error:nil];
	//delete Resources
	[fm removeItemAtPath:winePrefix error:nil];
	//rename ResoTemp to Resources
	[fm moveItemAtPath:[NSString stringWithFormat:@"%@/ResoTemp",contentsFold] toPath:[NSString stringWithFormat:@"%@/Resources",contentsFold] error:nil];
	//fix Reosurces to 777
	[self systemCommand:[NSString stringWithFormat:@"chmod 777 \"%@\"",winePrefix]];
	[fm release];
}

- (void)tryToUseGPUInfo
{
	//TODO if cannot read/write drive log error and skip
	
	//if user.reg doesn't exist, don't do anything
	if (!([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/user.reg",winePrefix]])) return;
	NSString *deviceID = @"error";
	NSString *vendorID = @"error";
	NSString *VRAM = @"error";
	NSArray *results = [[self systemCommand:@"system_profiler SPDisplaysDataType"] componentsSeparatedByString:@"\n"];
	int i;
	int findCounter = 0;
	int displaysLineCounter = 0;
	BOOL doTesting = NO;
	//need to go through backwards.  After finding a suffix "Online: Yes" then next VRAM Device ID and Vendor is the correct ones, exit after finding all 3
	// if we hit a prefix of "Displays:" a second time after start testing, we have gone too far.
	for (i = [results count] - 1; i >= 0; i--)
	{
		NSString *temp = [[results objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([temp hasSuffix:@"Online: Yes"])
		{
			doTesting = YES;
			continue;
		}
		if (doTesting)
		{
			if ([temp hasPrefix:@"Displays:"]) displaysLineCounter++;  // make sure somehting missing on some GPU will not pull info from 2 GPUs.
			if (displaysLineCounter > 1) findCounter=3;
			else if ([temp hasPrefix:@"Device ID:"])
			{
				deviceID = [[temp stringByReplacingOccurrencesOfString:@"Device ID:" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				findCounter++;
			}
			else if ([temp hasPrefix:@"Vendor:"])
			{
				vendorID = [temp substringFromIndex:[temp rangeOfString:@"("].location+1];
				vendorID = [[vendorID stringByReplacingOccurrencesOfString:@")" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				findCounter++;
			}
			else if ([temp hasPrefix:@"VRAM (Total):"])
			{
				VRAM = [temp stringByReplacingOccurrencesOfString:@"VRAM (Total): " withString:@""];
				VRAM = [[VRAM stringByReplacingOccurrencesOfString:@" MB" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				findCounter++;
			}
			
		}
		if (findCounter > 2) break;
	}
	//need to strip 0x off the front of deviceID and vendorID, and pad with 0's in front until its a total of 8 digits long.
	vendorID = [vendorID stringByReplacingOccurrencesOfString:@"0x" withString:@""];
	deviceID = [deviceID stringByReplacingOccurrencesOfString:@"0x" withString:@""];
	while ([vendorID length] < 8)
		vendorID = [NSString stringWithFormat:@"0%@",vendorID];
	while ([deviceID length] < 8)
		deviceID = [NSString stringWithFormat:@"0%@",deviceID];
	
	// write each of the 3 in the Registry if not = "error"
	//read in user.reg to an array
	NSArray *userRegContents = [self readFileToStringArray:[NSString stringWithFormat:@"%@/user.reg",winePrefix]];
	NSMutableArray *newUserRegContents = [NSMutableArray arrayWithCapacity:[userRegContents count]];
	BOOL deviceIDFound = NO;
	BOOL vendorIDFound = NO;
	BOOL VRAMFound = NO;
	BOOL startTesting = NO;
	for (NSString *item in userRegContents)
	{
		if ([item hasPrefix:@"[Software\\\\Wine\\\\Direct3D]"])
		{
			[newUserRegContents addObject:item];
			startTesting = YES;
			continue;
		}
		if (startTesting)
		{
			if ([item hasPrefix:@"\"VideoMemorySize\""] && !([VRAM isEqualToString:@"error"]))
			{
				[newUserRegContents addObject:[NSString stringWithFormat:@"\"VideoMemorySize\"=\"%@\"",VRAM]];
				VRAMFound = YES;
				continue;
			}
			else if ([item hasPrefix:@"\"VideoPciDeviceID\""] && !([deviceID isEqualToString:@"error"]))
			{
				[newUserRegContents addObject:[NSString stringWithFormat:@"\"VideoPciDeviceID\"=dword:%@",deviceID]];
				deviceIDFound = YES;
				continue;
			}
			else if ([item hasPrefix:@"\"VideoPciVendorID\""] && !([vendorID isEqualToString:@"error"]))
			{
				[newUserRegContents addObject:[NSString stringWithFormat:@"\"VideoPciVendorID\"=dword:%@",vendorID]];
				vendorIDFound = YES;
				continue;
			}
		}
		if (startTesting && [item hasPrefix:@"["])
		{
			// its out of the Direct3D section, write in any items still needed
			startTesting = NO;
			if ([[newUserRegContents lastObject] length] < 1) // just in case someone editing manually and didn't leave a space
				[newUserRegContents removeLastObject];
			if (!VRAMFound && !([VRAM isEqualToString:@"error"]))
				[newUserRegContents addObject:[NSString stringWithFormat:@"\"VideoMemorySize\"=\"%@\"",VRAM]];
			if (!deviceIDFound && !([deviceID isEqualToString:@"error"]))
				[newUserRegContents addObject:[NSString stringWithFormat:@"\"VideoPciDeviceID\"=dword:%@",deviceID]];
			if (!vendorIDFound && !([vendorID isEqualToString:@"error"]))
				[newUserRegContents addObject:[NSString stringWithFormat:@"\"VideoPciVendorID\"=dword:%@",vendorID]];
			[newUserRegContents addObject:@""];
		}
		//if it makes it through everything, then its a normal line that is needed as is.
		[newUserRegContents addObject:item];
	}
	//write array back to file
	[self writeStringArray:[NSArray arrayWithArray:newUserRegContents] toFile:[NSString stringWithFormat:@"%@/user.reg",winePrefix]];
	[self systemCommand:[NSString stringWithFormat:@"chmod 666 \"%@/user.reg\"",winePrefix]];
}

- (void)removeGPUInfo
{
	// TODO - skip if not on read/write volume
	NSArray *userRegContents = [self readFileToStringArray:[NSString stringWithFormat:@"%@/user.reg",winePrefix]];
	NSMutableArray *newUserRegContents = [NSMutableArray arrayWithCapacity:[userRegContents count]];
	BOOL deviceIDFound = NO;
	BOOL vendorIDFound = NO;
	BOOL VRAMFound = NO;
	BOOL startTesting = NO;
	for (NSString *item in userRegContents)
	{
		if ([item hasPrefix:@"[Software\\\\Wine\\\\Direct3D]"]) //make sure we are in the same place
		{
			[newUserRegContents addObject:item];
			startTesting = YES;
			continue;
		}
		if (startTesting)
		{
			if ([item hasPrefix:@"\"VideoMemorySize\""])
			{
				VRAMFound = YES;
				continue;
			}
			else if ([item hasPrefix:@"\"VideoPciDeviceID\""])
			{
				deviceIDFound = YES;
				continue;
			}
			else if ([item hasPrefix:@"\"VideoPciVendorID\""])
			{
				vendorIDFound = YES;
				continue;
			}
		}
		if ([item hasPrefix:@"["]) startTesting = NO;
		//if it makes it through everything, then its a normal line that is needed as is.
		[newUserRegContents addObject:item];
	}
	//write array back to file
	[self writeStringArray:[NSArray arrayWithArray:newUserRegContents] toFile:[NSString stringWithFormat:@"%@/user.reg",winePrefix]];
	[self systemCommand:[NSString stringWithFormat:@"chmod 666 \"%@/user.reg\"",winePrefix]];
}
- (void)fixFrameworksLibraries
{
    NSFileManager *fm = [NSFileManager defaultManager];
    //fix to have the right libXplugin for the OS version
    SInt32 majorVersion,minorVersion;
    Gestalt(gestaltSystemVersionMajor, &majorVersion);
    Gestalt(gestaltSystemVersionMinor, &minorVersion);
    NSString *symlinkName = [NSString stringWithFormat:@"%@/libXplugin.1.dylib",frameworksFold];
    NSString *mainFile = [NSString stringWithFormat:@"libXplugin.1.%d.%d.dylib",majorVersion,minorVersion];
    if (![fm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",frameworksFold,mainFile]])
    {
        NSLog(@"WARNING!!:  You are running Wineskin on an unsupported OS and there may be major problems!");
        [self systemCommand:[NSString stringWithFormat:@"echo \"WARNING!!:  You are running Wineskin on an unsupported OS and there may be major problems!\" >> \"%@\"",x11LogFile]];
        mainFile = @"/usr/lib/libXplugin.1.dylib";
    }
    [fm removeItemAtPath:symlinkName error:nil];
    [fm createSymbolicLinkAtPath:symlinkName withDestinationPath:mainFile error:nil];
    [self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@\"",symlinkName]];
	[fm release];
}
- (NSString *)setWindowManager
{
	if (fullScreenOption) return @"";//do not run quartz-wm in override->fullscreen
	NSString *quartzwmLine = [NSString stringWithFormat:@" +extension \"'%@/bin/quartz-wm'\"",frameworksFold];
	if (forceWrapperQuartzWM) return quartzwmLine;
	NSFileManager *fm = [NSFileManager defaultManager];
	//look for quartz-wm in all locations, if not found default to backup
	//should be in /usr/bin/quartz-wm or /opt/X11/bin/quartz-wm or /opt/local/bin/quartz-wm
	//find the newest version
	NSMutableArray *pathsToCheck = [NSMutableArray arrayWithCapacity:1];
	if ([fm fileExistsAtPath:@"/usr/bin/quartz-wm"])
		[pathsToCheck addObject:@"/usr/bin/quartz-wm"];
	if ([fm fileExistsAtPath:@"/opt/X11/bin/quartz-wm"])
		[pathsToCheck addObject:@"/opt/X11/bin/quartz-wm"];
	if ([fm fileExistsAtPath:@"/opt/local/bin/quartz-wm"])
		[pathsToCheck addObject:@"/opt/local/bin/quartz-wm"];
	while([pathsToCheck count] > 1) //go through list, remove all but newest version
	{
		NSString *indexZero = [self systemCommand:[NSString stringWithFormat:@"%@ --version",[pathsToCheck objectAtIndex:0]]];
		NSString *indexOne =[self systemCommand:[NSString stringWithFormat:@"%@ --version",[pathsToCheck objectAtIndex:1]]];
		NSMutableArray *indexZeroArray = [NSMutableArray arrayWithCapacity:4];
		NSMutableArray *indexOneArray = [NSMutableArray arrayWithCapacity:4];
		[indexZeroArray addObjectsFromArray:[indexZero componentsSeparatedByString:@"."]];
		[indexOneArray addObjectsFromArray:[indexOne componentsSeparatedByString:@"."]];
		if ([indexZeroArray count] < [indexOneArray count]) //make sure both are the same length for compare
		{
			while ([indexZeroArray count] < [indexOneArray count])
				[indexZeroArray addObject:@"0"];
		}
		else if ([indexOneArray count] < [indexZeroArray count])
		{
			while ([indexOneArray count] < [indexZeroArray count])
				[indexOneArray addObject:@"0"];
		}
		BOOL removed=NO;
		int i;
		for(i=0;i<[indexZeroArray count];i++)
		{
			NSComparisonResult result = [[indexZeroArray objectAtIndex:i] compare:[indexOneArray objectAtIndex:i] options:NSNumericSearch];
			if (result == NSOrderedAscending) //indexZeroArray is smaller, get rid of it
			{
				[pathsToCheck removeObjectAtIndex:0];
				removed=YES;
				break;
			}
			else if (result == NSOrderedDescending) //indexOneArray is smaller, get rid of it
			{
				[pathsToCheck removeObjectAtIndex:1];
				removed=YES;
				break;
			}
		}
		if (!removed) //they must be equal versions, pull second one out
			[pathsToCheck removeObjectAtIndex:1];
	}
	if ([pathsToCheck count] == 1)
		quartzwmLine = [NSString stringWithFormat:@" +extension \"'%@'\"",[pathsToCheck objectAtIndex:0]];
	[fm release];
	return quartzwmLine;
}

- (void)startX11
{
	// do not start X server for Winetricks listings.. its a waste of time.
	if ([wssCommand isEqualToString:@"WSS-winetricks"])
		if (([winetricksCommands count] == 2 && [[winetricksCommands objectAtIndex:1] isEqualToString:@"list"])
		    || ([winetricksCommands count] == 1 && ([[winetricksCommands objectAtIndex:0] isEqualToString:@"list"] || [[winetricksCommands objectAtIndex:0] hasPrefix:@"list-"])))
		{
			wineskinX11PID = @"Winetricks Listing, no X server needed";
			return;
		}
	//copying X11plist file over to /tmp to use... was needed in C++ for copy problems from /Volumes, may not be needed now... trying directly
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *wsX11PlistFile = [NSString stringWithFormat:@"%@/WSX11Prefs.plist",frameworksFold];
	//get current engine
	if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/version",frameworksFold]])
	{
		NSArray *tempArray = [self readFileToStringArray:[NSString stringWithFormat:@"%@/wswine.bundle/version",frameworksFold]];
		engineVersion = [tempArray objectAtIndex:0];
		NSLog(@"Using Engine %@",engineVersion);
	}
	//fix the Frameworks Libraires
	[self fixFrameworksLibraries];	
	//set up quartz-wm launch correctly
	NSString *quartzwmLine = [self setWindowManager];						  
	//copy the plist over
	[fm removeItemAtPath:x11PListFile error:nil];
	[fm copyItemAtPath:wsX11PlistFile toPath:x11PListFile error:nil];
	
	//make proper files and symlinks in /tmp/Wineskin
	[fm removeItemAtPath:@"/tmp/Wineskin" error:nil]; // try to remove old folder if you can
	[fm createDirectoryAtPath:@"/tmp/Wineskin" withIntermediateDirectories:YES attributes:nil error:nil];
	[self systemCommand:@"chmod 0777 /tmp/Wineskin"];
	//stuff for /tmp/Wineskin/bin
	[fm createSymbolicLinkAtPath:@"/tmp/Wineskin/bin" withDestinationPath:[NSString stringWithFormat:@"%@/bin",frameworksFold] error:nil];
	[self systemCommand:@"chmod -h 777 /tmp/Wineskin/bin"];
	//stuff for /tmp/Wineskin/lib
	[fm createSymbolicLinkAtPath:@"/tmp/Wineskin/lib" withDestinationPath:[NSString stringWithFormat:@"%@/bin",frameworksFold] error:nil];
	[self systemCommand:@"chmod -h 777 /tmp/Wineskin/lib"];
	//stuff for /tmp/Wineskin/share
	[fm createSymbolicLinkAtPath:@"/tmp/Wineskin/share" withDestinationPath:[NSString stringWithFormat:@"%@/bin",frameworksFold] error:nil];
	[self systemCommand:@"chmod -h 777 /tmp/Wineskin/share"];
	//stuff for Xmodmap
	[fm createSymbolicLinkAtPath:@"/tmp/Wineskin/.Xmodmap" withDestinationPath:[NSString stringWithFormat:@"%@/.Xmodmap",frameworksFold] error:nil];
	[self systemCommand:@"chmod -h 777 /tmp/Wineskin/.Xmodmap"];
	//change Info.plist to use main.nib (xquartz's nib) instead of MainMenu.nib (WineskinLauncher's nib)
	NSMutableDictionary* quickEdit1 = [[NSDictionary alloc] initWithContentsOfFile:infoPlistFile];
	[quickEdit1 setValue:@"X11Application" forKey:@"NSPrincipalClass"];
	[quickEdit1 setValue:@"main.nib" forKey:@"NSMainNibFile"];
	BOOL fileWriteWorked = [quickEdit1 writeToFile:infoPlistFile atomically:YES];
	[quickEdit1 release];
	if (!fileWriteWorked)
	{
		//error!  read only volume or other permissions problem, cannot run.
		NSLog(@"Error, cannot write to Info.plist, there are permission problems, or you are on a read-only volume. This cannot run from within a read-only dmg file.");
		CFUserNotificationDisplayNotice(10.0, 0, NULL, NULL, NULL, CFSTR("ERROR!"), (CFStringRef)@"ERROR! cannot write to Info.plist, there are permission problems, or you are on a read-only volume.\n\nThis cannot run from within a read-only dmg file.", NULL);
		wineskinX11PID = @"ERROR";
		return;
	}	
	//set up fontpath variable for server depending where X11 fonts are on the system
	NSString *wineskinX11FontPathPrefix = @"/opt/X11/share/fonts";
	if (![fm fileExistsAtPath:wineskinX11FontPathPrefix])
	{
		if ([fm fileExistsAtPath:@"/usr/X11/share/fonts"])
			wineskinX11FontPathPrefix=@"/usr/X11/share/fonts";
		else if ([fm fileExistsAtPath:@"/opt/local/share/fonts"])
			wineskinX11FontPathPrefix=@"/opt/local/share/fonts";
        else if ([fm fileExistsAtPath:@"/usr/X11/lib/X11/fonts"])
			wineskinX11FontPathPrefix=@"/usr/X11/lib/X11/fonts";
		else if ([fm fileExistsAtPath:@"/usr/X11R6/lib/X11/fonts"])
			wineskinX11FontPathPrefix=@"/usr/X11R6/lib/X11/fonts";
		else
			wineskinX11FontPathPrefix=[NSString stringWithFormat:@"%@/bin/fonts",frameworksFold];
	}
	NSString *wineskinX11FontPath = wineskinX11FontPath = [NSString stringWithFormat:@"-fp \"%@/75dpi,%@/100dpi,%@/cyrillic,%@/misc,%@/OTF,%@/Speedo,%@/TTF,%@/Type1,%@/util\"",wineskinX11FontPathPrefix,wineskinX11FontPathPrefix,wineskinX11FontPathPrefix,wineskinX11FontPathPrefix,wineskinX11FontPathPrefix,wineskinX11FontPathPrefix,wineskinX11FontPathPrefix,wineskinX11FontPathPrefix,wineskinX11FontPathPrefix];
	// set log variable
	NSString *logFileLocation;
	if (debugEnabled)
        logFileLocation = @"/dev/null";
	else
		logFileLocation=x11LogFile;
	//make sure the X11 lock files is gone before starting X11
	[fm removeItemAtPath:@"/tmp/.X11-unix" error:nil];
	//find WineskinX11 executable PID (this is only used for proper shut down, all other PID usage for X11 should be the Bundle PID
	//make first pid array
	NSArray *firstPIDlist = [self makePIDArray:@"WineskinX11"];	
	//Start WineskinX11
	wrapperBundlePID = [self systemCommand:[NSString stringWithFormat:@"export DISPLAY=%@;DYLD_FALLBACK_LIBRARY_PATH=\"%@\" \"%@/MacOS/WineskinX11\" %@ -depth %@ +xinerama -br %@ -xkbdir \"%@/bin/X11/xkb\"%@ > \"%@\" 2>&1 & echo \"$!\"",theDisplayNumber,dyldFallBackLibraryPath,contentsFold,theDisplayNumber,fullScreenResolutionBitDepth,wineskinX11FontPath,frameworksFold,quartzwmLine,logFileLocation]];
	//do loop compare to find correct wineskinX11PID, only try 3 times, then try again slower 5 times over 5 seconds
	wineskinX11PID = @"-1";
	BOOL match = YES;
	int i = 0;
	for (i=0;i<9;i++)
	{
		NSArray *secondPIDlist = [self makePIDArray:@"WineskinX11"];
		for(NSString *secondPIDlistItem in secondPIDlist)
		{
			if ([secondPIDlistItem isEqualToString:wrapperBundlePID]) continue;// skip the wrapper bundle PID and find the next
			match = NO;
			for(NSString *firstPIDlistItem in firstPIDlist)
				if ([secondPIDlistItem isEqualToString:firstPIDlistItem]) match = YES;
			if (!match)
			{
				wineskinX11PID = secondPIDlistItem;
				break;
			}
		}
		if (!match) break;
		if (i>2) usleep(1000000);
	}
	//if no PID found, log problem
	if ([wineskinX11PID isEqualToString:@"-1"])
		NSLog(@"Wineskin: Error! WineskinX11 PID not found, there may be unexpected errors on shut down!\n");
	//fix Info.plist back
	usleep(500000);
	//bring X11 to front before any windows are drawn
	[self bringToFront:wrapperBundlePID];
	NSMutableDictionary* quickEdit2 = [[NSDictionary alloc] initWithContentsOfFile:infoPlistFile];
	[quickEdit2 setValue:@"NSApplication" forKey:@"NSPrincipalClass"];
	[quickEdit2 setValue:@"MainMenu.nib" forKey:@"NSMainNibFile"];
	[quickEdit2 writeToFile:infoPlistFile atomically:YES];
	[quickEdit2 release];
	//get rid of X11 lock folder that shouldnt be needed
	[fm removeItemAtPath:@"/tmp/.X11-unix" error:nil];
	[fm release];
	return;
}
- (void)startXQuartz
{
	NSFileManager *fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:@"/Applications/Utilities/XQuartz.app/Contents/MacOS/X11.bin"])
	{
		NSLog(@"Error XQuartz not found, defaulting back to WineskinX11");
		useXQuartz = NO;
		[fm release];
		return;
	}
	if (!fullScreenOption)
	{
		[self systemCommand:@"open /Applications/Utilities/XQuartz.app"];
		theDisplayNumber = [self systemCommand:@"echo $DISPLAY"];
	}
	else
	{
		//make sure XQuartz is not already running
		//this is because it needs to be started with no Quartz-wm for override->fullscreen to function correctly.
		if ([[self systemCommand:@"killall -s X11.bin"] hasPrefix:@"kill"])
		{
			//already running, error and exit
			NSLog(@"Error: XQuartz cannot already be running if using Override Fullscreen option!  Please close XQuartz and try again!");
			CFUserNotificationDisplayNotice(0, 0, NULL, NULL, NULL, CFSTR("ERROR"), CFSTR("Error: XQuartz cannot already be running if using Override Fullscreen option!\n\nPlease close XQuartz and try again!"), NULL);
			killWineskin = YES;
			return;
		}
		//make first pid array
		NSArray *firstPIDlist = [self makePIDArray:@"X11.bin"];
		//start XQuartz
		xQuartzBundlePID = [self systemCommand:[NSString stringWithFormat:@"/Applications/Utilities/XQuartz.app/Contents/MacOS/X11.bin %@ > /dev/null & echo $!",theDisplayNumber]];
		//do loop compare to find correct X11.bin PID, only try 3 times, then try again slower 5 times over 5 seconds
		xQuartzX11BinPID = @"-1";
		BOOL match = YES;
		int i = 0;
		for (i=0;i<9;i++)
		{
			NSArray *secondPIDlist = [self makePIDArray:@"X11.bin"];
			for(NSString *secondPIDlistItem in secondPIDlist)
			{
				if ([secondPIDlistItem isEqualToString:xQuartzBundlePID]) continue;// skip the wrapper bundle PID and find the next
				match = NO;
				for(NSString *firstPIDlistItem in firstPIDlist)
					if ([secondPIDlistItem isEqualToString:firstPIDlistItem]) match = YES;
				if (!match)
				{
					xQuartzX11BinPID = secondPIDlistItem;
					break;
				}
			}
			if (!match) break;
			if (i>2) usleep(1000000);
		}
		//if no PID found, log problem
		if ([xQuartzX11BinPID isEqualToString:@"-1"])
			NSLog(@"Error! XQuartz X11.Bin PID not found, there may be unexpected errors on shut down!\n");
		//if started this way we need extra time or Wine may be gotten too too quickly
		usleep(1500000);
		[self bringToFront:xQuartzBundlePID];
	}
	[fm release];
	return;
}

- (void)bringToFront:(NSString *)thePid
{
	/*this has been very problematic.  Need to detect front most app, and try to make WineskinX11 go frontmost
	 *recheck and retry different ways until it is the frontmost, or just fail with a NSLog.
	 *only attempt if WineskinX11 is still actually running
	 */
	if ([self isPID:thePid named:appNameWithPath])
	{
		NSWorkspace* workspace = [NSWorkspace sharedWorkspace];
		int i=0;
		for (i=0;i<5;i++)
		{
			//get frontmost application information
			NSDictionary* frontMostAppInfo = [workspace activeApplication];
			//get the PSN of the frontmost app
			UInt32 lowLong = [[frontMostAppInfo objectForKey:@"NSApplicationProcessSerialNumberLow"] longValue];
			UInt32 highLong = [[frontMostAppInfo objectForKey:@"NSApplicationProcessSerialNumberHigh"] longValue];
			ProcessSerialNumber currentAppPSN = {highLong,lowLong};
			//Get Apple Process for WineskinX11 PID
			ProcessSerialNumber PSN = {kNoProcess, kNoProcess};
			GetProcessForPID((pid_t)[thePid intValue], &PSN);
			//check if we are in the front
			if(PSN.lowLongOfPSN == currentAppPSN.lowLongOfPSN && PSN.highLongOfPSN == currentAppPSN.highLongOfPSN)
			{
				//WineskinX11 is frontmost
				/* Testing Data
				if (i==0)
					NSLog(@"WSTEST\nWSTEST\nThe App was detected as frontmost!!!! No method used\nWSTEST\nWSTEST");
				else if (i==1)
					NSLog(@"WSTEST\nWSTEST\nThe App was detected as frontmost!!!! NSWorkSpace launchApplication method successful\nWSTEST\nWSTEST");
				else if (i==2)
					NSLog(@"WSTEST\nWSTEST\nThe App was detected as frontmost!!!! system open method successful\nWSTEST\nWSTEST");
				else if (i==3)
					NSLog(@"WSTEST\nWSTEST\nThe App was detected as frontmost!!!! NSAppleScript activate method successful\nWSTEST\nWSTEST");
				else if (i==3)
					NSLog(@"WSTEST\nWSTEST\nThe App was detected as frontmost!!!! osascript activate method successful\nWSTEST\nWSTEST");
				 */
				break;
			}
			else
			{
				//need to bring to front
				if (i==0)
					[workspace launchApplication:appNameWithPath];
				else if (i==1)
					[self systemCommand:[NSString stringWithFormat:@"open \"%@\"",appNameWithPath]];
				else if (i==2)
				{
					NSString *theScript = [NSString stringWithFormat:@"tell Application \"%@\" to activate",appNameWithPath];
					NSAppleScript *bringToFrontScript = [[NSAppleScript alloc] initWithSource:theScript];
					[bringToFrontScript executeAndReturnError:nil];
					[bringToFrontScript release];
				}
				else if (i==3)
					[self systemCommand:[NSString stringWithFormat:@"arch -i386 /usr/bin/osascript -e \"tell application \\\"%@\\\" to activate\"",appNameWithPath]];
				else
				{
					//only gets here if app never front most and breaks
					NSLog(@"Application failed to ever become frontmost");
					break;
				}
			}
		}
	}
}

- (void)installEngine
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSMutableArray *wswineBundleContentsList = [NSMutableArray arrayWithCapacity:2];
	//get directory contents of wswine.bundle
	NSArray *files = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/",frameworksFold] error:nil];
	for (NSString *file in files)
		if ([file hasSuffix:@".bundle.tar.7z"]) [wswineBundleContentsList addObject:[file stringByReplacingOccurrencesOfString:@".tar.7z" withString:@""]];
	//if the .tar.7z files exist, continue with this
	if ([wswineBundleContentsList count] > 0) isIce = YES;
	if (!isIce)
	{
		[fm release];
		return;
	}
	//install Wine on the system
	NSString *wineFile = @"OOPS";
	for (NSString *item in wswineBundleContentsList)
		if ([item hasPrefix:@"WSWine"] && [item hasSuffix:@"ICE.bundle"]) wineFile = [NSString stringWithFormat:@"%@",item];
	if ([wineFile isEqualToString:@"OOPS"])
	{
		NSLog(@"Warning! This appears to be Wineskin ICE, but there is a problem in the Engine files in the wrapper.  They are either corrupted or missing.  The program may fail to launch!");
		CFUserNotificationDisplayNotice(10.0, 0, NULL, NULL, NULL, CFSTR("WARNING!"), (CFStringRef)@"Warning! This appears to be Wineskin ICE, but there is a problem in the Engine files in the wrapper.\n\nThey are either corrupted or missing.\n\nThe program may fail to launch!", NULL);
		usleep(3000000);
	}
	//get md5
	NSString *wineFileMd5 = [[self systemCommand:[NSString stringWithFormat:@"md5 -r \"%@/wswine.bundle/%@.tar.7z\"",frameworksFold,wineFile]] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@" %@/wswine.bundle/%@.tar.7z",frameworksFold,wineFile] withString:@""];
	NSString *wineFileInstalledName = [NSString stringWithFormat:@"%@%@.bundle",[wineFile stringByReplacingOccurrencesOfString:@"bundle" withString:@""],wineFileMd5];
	//make ICE folder if it doesn't exist
	[fm createDirectoryAtPath:[NSHomeDirectory() stringByAppendingString:@"/Library/Application Support/Wineskin/Engines/ICE"] withIntermediateDirectories:YES attributes:nil error:nil];
	// delete out extra bundles or tars in engine bundle first
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/%@.tar",frameworksFold,wineFile] error:nil];
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/%@",frameworksFold,wineFile] error:nil];
	//get directory contents of NSHomeDirectory()/Library/Application Support/Wineskin/Engines/ICE
	NSArray *iceFiles = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Engines/ICE",NSHomeDirectory()] error:nil];
	//if Wine version is not installed...
	BOOL wineInstalled = NO;
	for (NSString *file in iceFiles)
		if ([file isEqualToString:wineFileInstalledName]) wineInstalled = YES;
	CFUserNotificationRef pDlg = NULL;
	if (!wineInstalled)
	{
		// pop up install notice
		SInt32 nRes = 0;
		NSString *icnsPath = [[[NSBundle mainBundle] bundlePath] stringByReplacingOccurrencesOfString:@".app/Contents/Frameworks/bin" withString:@".app/Contents/Resources/Wineskin.icns"];
		NSLog(@"icnsPath = %@",icnsPath);
		NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:6];
		[dict setObject:@"*****Wineskin ICE Detected*****\n" forKey:(NSString *)kCFUserNotificationAlertHeaderKey];
		[dict setObject:@"Wineskin Engine ICE version installing\n\nICE = Installable Compressed Engine\n\n" forKey:(NSString *)kCFUserNotificationAlertMessageKey];
		[dict setObject:@"I'll be patient!" forKey:(NSString *)kCFUserNotificationDefaultButtonTitleKey];
		[dict setObject:@"true" forKey:(NSString *)kCFUserNotificationProgressIndicatorValueKey];
		[dict setObject:[NSURL fileURLWithPath:icnsPath] forKey:(NSString *)kCFUserNotificationIconURLKey];
		pDlg = CFUserNotificationCreate(NULL,0,kCFUserNotificationNoteAlertLevel | kCFUserNotificationNoDefaultButtonFlag | CFUserNotificationCheckBoxChecked(0) | CFUserNotificationSecureTextField(0) | CFUserNotificationPopUpSelection(0),&nRes,(CFDictionaryRef)dict);
		//if the Wine bundle is not located in the install folder, then uncompress it and move it over there.
		if (!wineInstalled)
		{
			system([[NSString stringWithFormat:@"\"%@/wswine.bundle/7za\" x \"%@/wswine.bundle/%@.tar.7z\" \"-o/%@/wswine.bundle\"",frameworksFold,frameworksFold,wineFile,frameworksFold] UTF8String]);
			system([[NSString stringWithFormat:@"/usr/bin/tar -C \"%@/wswine.bundle\" -xf \"%@/wswine.bundle/%@.tar\"",frameworksFold,frameworksFold,wineFile] UTF8String]);
			[fm removeItemAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/%@.tar",frameworksFold,wineFile] error:nil];
			//have uncompressed version now, move it to ICE folder.
			[fm moveItemAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/%@",frameworksFold,wineFile] toPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Engines/ICE/%@",NSHomeDirectory(),wineFileInstalledName] error:nil];
		}
	}
	//make/remake the symlink in wswine.bundle to point to the correct location
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/bin",frameworksFold] error:nil];
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/lib",frameworksFold] error:nil];
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/share",frameworksFold] error:nil];
	[fm removeItemAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/version",frameworksFold] error:nil];
	[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/bin",frameworksFold] withDestinationPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Engines/ICE/%@/bin",NSHomeDirectory(),wineFileInstalledName] error:nil];
	[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/lib",frameworksFold] withDestinationPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Engines/ICE/%@/lib",NSHomeDirectory(),wineFileInstalledName] error:nil];
	[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/share",frameworksFold] withDestinationPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Engines/ICE/%@/share",NSHomeDirectory(),wineFileInstalledName] error:nil];
	[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/wswine.bundle/version",frameworksFold] withDestinationPath:[NSString stringWithFormat:@"%@/Library/Application Support/Wineskin/Engines/ICE/%@/version",NSHomeDirectory(),wineFileInstalledName] error:nil];
	[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/wswine.bundle/bin\"",frameworksFold]];
	[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/wswine.bundle/lib\"",frameworksFold]];
	[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/wswine.bundle/share\"",frameworksFold]];
	[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/wswine.bundle/version\"",frameworksFold]];
	//clear the pop up
	CFUserNotificationCancel(pDlg);
	[fm release];
}

- (void)setToVirtualDesktop:(NSString *)resolution named:(NSString *)desktopName
{
	// TODO test if on read/write volume first
	//read in user.reg to an array
	NSArray *userRegContents = [self readFileToStringArray:[NSString stringWithFormat:@"%@/user.reg",winePrefix]];
	NSMutableArray *newUserRegContents = [NSMutableArray arrayWithCapacity:[userRegContents count]];
	BOOL eFound = NO;
	BOOL eDFound = NO;
	BOOL eFixMade = NO;
	BOOL eDFixMade = NO;
	for (NSString *item in userRegContents)
	{
		//if it finds "[Software\\Wine\\Explorer]" add it and make sure next line is set right
		if ([item hasPrefix:@"[Software\\\\Wine\\\\Explorer]"])
		{
			[newUserRegContents addObject:item];
			[newUserRegContents addObject:[NSString stringWithFormat:@"\"Desktop\"=\"%@\"",desktopName]];
			[newUserRegContents addObject:@""];
			eFixMade = YES;
			eFound = YES;
			continue;
		}
		if ([item hasPrefix:@"[Software\\\\Wine\\\\Explorer\\\\Desktops]"])
		{
			[newUserRegContents addObject:item];
			[newUserRegContents addObject:[NSString stringWithFormat:@"\"%@\"=\"%@\"",desktopName,[resolution stringByReplacingOccurrencesOfString:@" " withString:@"x"]]];
			[newUserRegContents addObject:@""];
			eDFixMade = YES;
			eDFound = YES;
			continue;
		}
		if (eFound && !([item hasPrefix:@"["])) continue;
		else eFound = NO;
		if (eDFound && !([item hasPrefix:@"["])) continue;
		else eDFound = NO;
		//if it makes it thorugh everything, then its a normal line that is needed.
		[newUserRegContents addObject:item];
	}
	//if either of the lines were never found, add them at the end with correct entries
	if (!eFixMade)
	{
		[newUserRegContents addObject:@""];
		[newUserRegContents addObject:@"[Software\\\\Wine\\\\Explorer]"];
		[newUserRegContents addObject:[NSString stringWithFormat:@"\"Desktop\"=\"%@\"",desktopName]];
	}
	if (!eDFixMade)
	{
		[newUserRegContents addObject:@""];
		[newUserRegContents addObject:@"[Software\\\\Wine\\\\Explorer\\\\Desktops]"];
		[newUserRegContents addObject:[NSString stringWithFormat:@"\"%@\"=\"%@\"",desktopName,[resolution stringByReplacingOccurrencesOfString:@" " withString:@"x"]]];
	}
	//write array back to file
	[self writeStringArray:[NSArray arrayWithArray:newUserRegContents] toFile:[NSString stringWithFormat:@"%@/user.reg",winePrefix]];
	[self systemCommand:[NSString stringWithFormat:@"chmod 666 \"%@/user.reg\"",winePrefix]];
}

- (void)setToNoVirtualDesktop
{
	// TODO test if on read/write volume first
	//if file doesn't exist, don't do anything
	if (!([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/user.reg",winePrefix]]))
		return;
	//read in user.reg to an array
	NSArray *userRegContents = [self readFileToStringArray:[NSString stringWithFormat:@"%@/user.reg",winePrefix]];
	NSMutableArray *newUserRegContents = [NSMutableArray arrayWithCapacity:[userRegContents count]];
	BOOL eFound = NO;
	BOOL eDFound = NO;
	for (NSString *item in userRegContents)
	{
		//if it finds "[Software\\Wine\\Explorer]" add it and make sure next line is set right
		if ([item hasPrefix:@"[Software\\\\Wine\\\\Explorer]"])
		{
			[newUserRegContents addObject:item];
			[newUserRegContents addObject:@""];
			eFound = YES;
			continue;
		}
		if ([item hasPrefix:@"[Software\\\\Wine\\\\Explorer\\\\Desktops]"])
		{
			[newUserRegContents addObject:item];
			[newUserRegContents addObject:@""];
			eDFound = YES;
			continue;
		}
		if (eFound && !([item hasPrefix:@"["])) continue;
		else eFound = NO;
		if (eDFound && !([item hasPrefix:@"["])) continue;
		else eDFound = NO;
		//if it makes it thorugh everything, then its a normal line that is needed.
		[newUserRegContents addObject:item];
	}
	//write array back to file
	[self writeStringArray:[NSArray arrayWithArray:newUserRegContents] toFile:[NSString stringWithFormat:@"%@/user.reg",winePrefix]];
	[self systemCommand:[NSString stringWithFormat:@"chmod 666 \"%@/user.reg\"",winePrefix]];
}

- (NSArray *)readFileToStringArray:(NSString *)theFile
{
	return [[NSString stringWithContentsOfFile:theFile encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
}

- (void)writeStringArray:(NSArray *)theArray toFile:(NSString *)theFile
{
	[[NSFileManager defaultManager] removeItemAtPath:theFile error:nil];
	[[theArray componentsJoinedByString:@"\n"] writeToFile:theFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
	[self systemCommand:[NSString stringWithFormat:@"chmod 777 \"%@\"",theFile]];
}

- (BOOL)isPID:(NSString *)pid named:(NSString *)name
{
    if ([pid isEqualToString:@""])
    {
        NSLog(@"INVALID PID SENT TO isPID!!!");
    }
	if ([[self systemCommand:[NSString stringWithFormat:@"ps -p \"%@\" | grep \"%@\"",pid,name]] length] < 1) return NO;
	return YES;
}

- (NSString *)startWine
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *returnPID=@"-1";
	if (nonStandardRun)
	{
		[self setToNoVirtualDesktop];
		if ([wssCommand isEqualToString:@"WSS-wineprefixcreate"] || [wssCommand isEqualToString:@"WSS-wineprefixcreatenoregs"] || [wssCommand isEqualToString:@"WSS-wineboot"])
		{
			NSString *wineDebugLine = @"err-all,warn-all,fixme-all,trace-all";
			//remove the .update-timestamp file
			[fm removeItemAtPath:[NSString stringWithFormat:@"%@/.update-timestamp",winePrefix] error:nil];
			//calling wineboot is a simple builtin refresh that needs to NOT prompt for gecko
			NSString *mshtmlLine = @"";
			if ([wssCommand isEqualToString:@"WSS-wineboot"]) mshtmlLine = @"export WINEDLLOVERRIDES=\"mscoree,mshtml=\";";
			[self systemCommand:[NSString stringWithFormat:@"%@export WINEDEBUG=%@;export PATH=\"%@/wswine.bundle/bin:%@/bin:$PATH:/opt/local/bin:/opt/local/sbin\";export DISPLAY=%@;export WINEPREFIX=\"%@\";DYLD_FALLBACK_LIBRARY_PATH=\"%@\" wine wineboot > \"/dev/null\" 2>&1",mshtmlLine,wineDebugLine,frameworksFold,frameworksFold,theDisplayNumber,winePrefix,dyldFallBackLibraryPath]];
			usleep(3000000);
			if ([wssCommand isEqualToString:@"WSS-wineprefixcreate"]) //only runs on build new wrapper, and rebuild
			{
				//make sure windows/profiles is using users folder
				[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/windows/profiles",winePrefix] error:nil];
				[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/windows/profiles",winePrefix] withDestinationPath:@"../users" error:nil];							
				[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/windows/profiles\"",winePrefix]];
				//rename new user folder to Wineskin and make symlinks
				if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/drive_c/users/%@",winePrefix,NSUserName()]])
				{
					[fm moveItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/%@",winePrefix,NSUserName()] toPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin",winePrefix] error:nil];
					[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/users/%@",winePrefix,NSUserName()] withDestinationPath:@"Wineskin" error:nil];
					[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/users/%@\"",winePrefix,NSUserName()]];
				}
				else if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/drive_c/users/crossover",winePrefix]])
				{
					[fm moveItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/crossover",winePrefix] toPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin",winePrefix] error:nil];
					[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/users/crossover",winePrefix] withDestinationPath:@"Wineskin" error:nil];
					[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/users/crossover\"",winePrefix]];
				}
				else //this shouldn't ever happen.. but what the heck
				{
					[fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin",winePrefix] withIntermediateDirectories:YES attributes:nil error:nil];
					[fm createSymbolicLinkAtPath:[NSString stringWithFormat:@"%@/drive_c/users/%@",winePrefix,NSUserName()] withDestinationPath:@"Wineskin" error:nil];
					[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/drive_c/users/%@\"",winePrefix,NSUserName()]];
				}
				//load Wineskin default reg entries
				[self systemCommand:[NSString stringWithFormat:@"export WINEDEBUG=%@;export PATH=\"%@/wswine.bundle/bin:%@/bin:$PATH:/opt/local/bin:/opt/local/sbin\";export DISPLAY=%@;export WINEPREFIX=\"%@\";DYLD_FALLBACK_LIBRARY_PATH=\"%@\" wine regedit \"%@/../Wineskin.app/Contents/Resources/remakedefaults.reg\" > \"/dev/null\" 2>&1",wineDebugLine,frameworksFold,frameworksFold,theDisplayNumber,winePrefix,dyldFallBackLibraryPath,contentsFold]];
				usleep(5000000);
			}
			//fix user name entires over to Wineskin
			NSArray *userReg = [self readFileToStringArray:[NSString stringWithFormat:@"%@/user.reg",winePrefix]];
			NSMutableArray *newUserReg = [NSMutableArray arrayWithCapacity:[userReg count]];
			for (NSString *item in userReg)
				[newUserReg addObject:[item stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"C:\\users\\%@",NSUserName()] withString:@"C:\\users\\Wineskin"]];
			[self writeStringArray:[NSArray arrayWithArray:newUserReg] toFile:[NSString stringWithFormat:@"%@/user.reg",winePrefix]];
			[self systemCommand:[NSString stringWithFormat:@"chmod 666 \"%@/user.reg\"",winePrefix]];
			NSArray *userDefReg = [self readFileToStringArray:[NSString stringWithFormat:@"%@/userdef.reg",winePrefix]];
			NSMutableArray *newUserDefReg = [NSMutableArray arrayWithCapacity:[userDefReg count]];
			for (NSString *item in userDefReg)
				[newUserDefReg addObject:[item stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"C:\\users\\%@",NSUserName()] withString:@"C:\\users\\Wineskin"]];
			[self writeStringArray:[NSArray arrayWithArray:newUserDefReg] toFile:[NSString stringWithFormat:@"%@/userdef.reg",winePrefix]];
			// need Temp folder in Wineskin folder
			[fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/Temp",winePrefix] withIntermediateDirectories:YES attributes:nil error:nil];
			// do a chmod on the whole wrapper to 755... shouldn't breka anything but should prevent issues.
			// Task Number 3221715 Fix Wrapper Permissions
			//cocoa command don't seem to be working right, but chmod system command works fine.
			// cannot 755 the whole wrapper and then change to 777s or this can break the wrapper for non-Admin users.
			//[self systemCommand:[NSString stringWithFormat:@"chmod 755 \"%@\"",appNameWithPath]];
			// need to chmod 777 on Contents, Resources, and Resources/* for multiuser fix on same machine
			[self systemCommand:[NSString stringWithFormat:@"chmod 777 \"%@\"",contentsFold]];
			[self systemCommand:[NSString stringWithFormat:@"chmod 777 \"%@\"",winePrefix]];
			[self systemCommand:[NSString stringWithFormat:@"chmod 777 \"%@\"",frameworksFold]];
			[self systemCommand:[NSString stringWithFormat:@"chmod 777 \"%@/wswine.bundle\"",frameworksFold]];//for ICE symlinks
			[self systemCommand:[NSString stringWithFormat:@"chmod -R 777 \"%@/drive_c\"",winePrefix]];
			NSArray *tmpy2 = [fm contentsOfDirectoryAtPath:winePrefix error:nil];
			for (NSString *item in tmpy2)
				[self systemCommand:[NSString stringWithFormat:@"chmod 777 \"%@/%@\"",winePrefix,item]];
			NSArray *tmpy3 = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/dosdevices",winePrefix] error:nil];
			for (NSString *item in tmpy3)
				[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/dosdevices/%@\"",winePrefix,item]];
		}
		else if ([wssCommand isEqualToString:@"WSS-winetricks"])
		{
			NSString *wineDebugLine = @"err+all,warn-all,fixme+all,trace-all";
			if (([winetricksCommands count] == 2 && [[winetricksCommands objectAtIndex:1] isEqualToString:@"list"])
			    || ([winetricksCommands count] == 1 && ([[winetricksCommands objectAtIndex:0] isEqualToString:@"list"] || [[winetricksCommands objectAtIndex:0] hasPrefix:@"list-"]))) //just getting a list of packages... X should NOT be running.
				[self systemCommand:[NSString stringWithFormat:@"export WINEDEBUG=%@;cd \"%@/../Wineskin.app/Contents/Resources\";export PATH=\"$PWD:%@/wswine.bundle/bin:%@/bin:$PATH:/opt/local/bin:/opt/local/sbin\";export DISPLAY=%@;export WINEPREFIX=\"%@\";DYLD_FALLBACK_LIBRARY_PATH=\"%@\" winetricks --no-isolate %@ > \"%@/Logs/WinetricksTemp.log\"",wineDebugLine,contentsFold,frameworksFold,frameworksFold,theDisplayNumber,winePrefix,dyldFallBackLibraryPath,[winetricksCommands componentsJoinedByString:@" "],winePrefix]];
			else
				[self systemCommand:[NSString stringWithFormat:@"export WINEDEBUG=%@;cd \"%@/../Wineskin.app/Contents/Resources\";export PATH=\"$PWD:%@/wswine.bundle/bin:%@/bin:$PATH:/opt/local/bin:/opt/local/sbin\";export DISPLAY=%@;export WINEPREFIX=\"%@\";%@DYLD_FALLBACK_LIBRARY_PATH=\"%@\" winetricks --no-isolate \"%@\" > \"%@/Logs/Winetricks.log\" 2>&1",wineDebugLine,contentsFold,frameworksFold,frameworksFold,theDisplayNumber,winePrefix,cliCustomCommands,dyldFallBackLibraryPath,[winetricksCommands componentsJoinedByString:@"\" \""],winePrefix]];
			usleep(5000000); // sometimes it dumps out slightly too fast... just hold for a few seconds
		}
	}
	else //Normal Wine Run
	{
		//set desktop name for VD
        NSString *virtualDesktopName = [[appNameWithPath substringFromIndex:[appNameWithPath rangeOfString:@"/" options:NSBackwardsSearch].location+1] stringByReplacingOccurrencesOfString:@".app" withString:@""];
		//edit reg entiries for VD settings
		if ([vdResolution isEqualToString:@"novd"]) [self setToNoVirtualDesktop];
		else [self setToVirtualDesktop:vdResolution named:virtualDesktopName];
		// if Wineserver was already running, use the same one, so no need to do X or keepthe daemon running
		if (![wineserverPIDToCheck isEqualToString:@"-9"])// -9 means its not running for sure as the temp files didn't exist
            if ([self isPID:wineserverPIDToCheck named:@"wineserver"])
            {
                returnPID = wineserverPIDToCheck;
                killWineskin = YES;
                theDisplayNumber = [[self readFileToStringArray:displayNumberFile] objectAtIndex:0];
            }
		//write out new display file
		[self writeStringArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@\n",theDisplayNumber],nil] toFile:displayNumberFile];
		NSString *wineDebugLine;
        NSString *wineLogFileLocal = [NSString stringWithFormat:@"%@",wineLogFile];
		//set log file names, and stuff
		if (debugEnabled && !fullScreenOption) //standard log
			wineDebugLine = [NSString stringWithFormat:@"%@",wineDebugLineFromPlist];
		else if (debugEnabled && fullScreenOption) //always need a log with x11settings
			wineDebugLine = [NSString stringWithFormat:@"%@,trace+x11settings",wineDebugLineFromPlist];
		else if (!debugEnabled && fullScreenOption) //need log for reso changes
			wineDebugLine = @"err-all,warn-all,fixme-all,trace+x11settings";
		else //this should be rootless with no debug... don't need a log of any type.
		{
			wineLogFileLocal = @"/dev/null";
			wineDebugLine = @"err-all,warn-all,fixme-all,trace-all";
		}
		//fix start.exe line
		NSString *startExeLine = @"";
		if (runWithStartExe) startExeLine = @" start /unix";		
        //make first pid array
        NSArray *firstPIDlist;
        if (![returnPID isEqualToString:wineserverPIDToCheck])
            firstPIDlist = [self makePIDArray:@"wineserver"];
		//Wine start section... if opening files handle differently.
		if (openingFiles)
			for (NSString *item in filesToRun) //start wine with files
            {
                //don't try to run things xorg sometimes passes back stupidly...
                BOOL breakOut = NO;
                NSArray *breakStrings = [NSArray arrayWithObjects:@"/opt/X11/share/fonts",@"/usr/X11/share/fonts",@"/opt/local/share/fonts",@"/usr/X11/lib/X11/fonts",@"/usr/X11R6/lib/X11/fonts",[NSString stringWithFormat:@"%@/bin/fonts",frameworksFold],nil];
                for (NSString *breakItem in breakStrings)
                {
                    if ([item hasPrefix:breakItem])
                    {
                        breakOut = YES;
                        break;
                    }
                }
                if (breakOut) break;
				[self systemCommand:[NSString stringWithFormat:@"export PATH=\"%@/wswine.bundle/bin:%@/bin:$PATH:/opt/local/bin:/opt/local/sbin\";%@export WINEDEBUG=%@;export DISPLAY=%@;export WINEPREFIX=\"%@\";%@cd \"%@/wswine.bundle/bin\";DYLD_FALLBACK_LIBRARY_PATH=\"%@\" wine start /unix \"%@\" > \"%@\" 2>&1 &",frameworksFold,frameworksFold,uLimitNumber,wineDebugLine,theDisplayNumber,winePrefix,cliCustomCommands,frameworksFold,dyldFallBackLibraryPath,item,wineLogFileLocal]];
            }
		else  //launch Wine normally
			[self systemCommand:[NSString stringWithFormat:@"export PATH=\"%@/wswine.bundle/bin:%@/bin:$PATH:/opt/local/bin:/opt/local/sbin\";%@export WINEDEBUG=%@;export DISPLAY=%@;export WINEPREFIX=\"%@\";%@cd \"%@\";DYLD_FALLBACK_LIBRARY_PATH=\"%@\" wine%@ \"%@\"%@ > \"%@\" 2>&1 &",frameworksFold,frameworksFold,uLimitNumber,wineDebugLine,theDisplayNumber,winePrefix,cliCustomCommands,wineRunLocation,dyldFallBackLibraryPath,startExeLine,wineRunFile,programFlags,wineLogFileLocal]];
		vdResolution = [vdResolution stringByReplacingOccurrencesOfString:@"x" withString:@" "];
        if (![returnPID isEqualToString:wineserverPIDToCheck])
        {
            //do loop compare to find correct PID, only try 3 times, then try again slower 5 times over 5 seconds
            BOOL match = YES;
            int i = 0;
            for (i=0;i<9;i++)
            {
                NSArray *secondPIDlist = [self makePIDArray:@"wineserver"];
                for (NSString *item in secondPIDlist)
                    for(NSString *secondPIDlistItem in secondPIDlist)
                    {
                        match = NO;
                        for(NSString *firstPIDlistItem in firstPIDlist)
                            if ([secondPIDlistItem isEqualToString:firstPIDlistItem]) match = YES;
                        if (!match)
                        {
                            returnPID = secondPIDlistItem;
                            break;
                        }
                    }
                if (!match) break;
                if (i>2) usleep(1000000);
            }
        }
        //if no PID found, log message and quit
        if ([returnPID isEqualToString:@"-1"])
        {
            //NSLog(@"Error! launching wineserver failed! no new wineserver PID found!\n");
            //CFUserNotificationDisplayNotice(0, 0, NULL, NULL, NULL, CFSTR("Wineskin Error"), (CFStringRef)@"ERROR! Launching wineserver failed! No new wineserver PID found!", NULL);
            [fm release];
            killWineskin = YES;
            return @"-1";
        }
        if (![returnPID isEqualToString:wineserverPIDToCheck])
            [self writeStringArray:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@\n",returnPID],nil] toFile:wineserverPIDFile];
	}
	[fm release];
	return returnPID;
}

- (void)sleepAndMonitor
{
	NSFileManager *fm = [NSFileManager defaultManager];
    NSString *timeStampFile = [NSString stringWithFormat:@"%@/Logs/.timestamp",winePrefix];
    NSString *logFolder = [NSString stringWithFormat:@"%@/Logs",winePrefix];
	if (useGamma) [self setGamma:gammaCorrection];
	NSString *newScreenReso;
    NSString *xRandRTempFile = @"/tmp/WineskinXrandrTempFile";
    NSString *timestampChecker = [NSString stringWithFormat:@"find \"%@\" -type f newer \"%@\"",logFolder,timeStampFile];
	BOOL fixGamma = NO;
	int fixGammaCounter = 0;
    if (fullScreenOption)
    {
        [self systemCommand:[NSString stringWithFormat:@"> \"%@\"",timeStampFile]];
        [self systemCommand:[NSString stringWithFormat:@"> \"%@\"",wineTempLogFile]];
    }
	while ([self isPID:wineServerPID named:@"wineserver"])
	{
		//check for xrandr made files in /tmp
		if (useGamma)
		{
			if ([fm fileExistsAtPath:xRandRTempFile])
			{
                [fm removeItemAtPath:xRandRTempFile error:nil];
				///tmp/WineskinXrandrTempFile is written by WineskinX11 when there is a resolution change
                //when this happens Gamma is set to default, so we need to fix it, but there could be a delay, so it needs to try a few times over a few moments before giving up.
				fixGamma = YES;
				fixGammaCounter = 0;
			}
		}
		//if WineskinX11 is no longer running, tell wineserver to close
		if (!useXQuartz)
			if (![self isPID:wrapperBundlePID named:@"WineskinX11"])
				[self systemCommand:[NSString stringWithFormat:@"export PATH=\"%@/wswine.bundle/bin:%@/bin:$PATH:/opt/local/bin:/opt/local/sbin\";export DISPLAY=%@;export WINEPREFIX=\"%@\";cd \"%@/wswine.bundle/bin\";DYLD_FALLBACK_LIBRARY_PATH=\"%@\" wineserver -k > /dev/null 2>&1",frameworksFold,frameworksFold,theDisplayNumber,winePrefix,frameworksFold,dyldFallBackLibraryPath]];
		//if running in override fullscreen, need to handle resolution changes
		if(fullScreenOption)
		{
			//compare to timestamp, if log is newer, we need to check it out.
            if ([self systemCommand:timestampChecker])
            {
				NSArray *tempArray = [self readFileToStringArray:wineLogFile];
				[self systemCommand:[NSString stringWithFormat:@"> \"%@\"",wineLogFile]];
                [self systemCommand:[NSString stringWithFormat:@"> \"%@\"",timeStampFile]];
				if (debugEnabled)
                {
                    NSArray *oldDataArray = [self readFileToStringArray:wineTempLogFile];
                    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[oldDataArray count]];
                    [temp addObjectsFromArray:oldDataArray];
                    [temp addObjectsFromArray:tempArray];
                    [self writeStringArray:temp toFile:wineTempLogFile];
                }
				//now find resolution, and change it
				for (NSString *item in tempArray)
				{
					if ([item hasPrefix:@"trace:x11settings:X11DRV_ChangeDisplaySettingsEx width="])
					{
						newScreenReso = [item stringByReplacingOccurrencesOfString:@"trace:x11settings:X11DRV_ChangeDisplaySettingsEx width=" withString:@""];
						newScreenReso = [newScreenReso stringByReplacingOccurrencesOfString:@"height=" withString:@""];
						newScreenReso = [newScreenReso substringToIndex:[newScreenReso rangeOfString:@" bpp="].location];
						[self setResolution:newScreenReso];
						NSLog(@"Changing resolution to request: %@",newScreenReso);
					}
				}
			}
		}
		if (fixGamma)
		{
			[self setGamma:gammaCorrection];
			fixGammaCounter++;
		}
		if (fixGammaCounter > 6) fixGamma = NO;
		usleep(1250000); // sleeping in background 1.25 seconds
	}
    [fm removeItemAtPath:timeStampFile error:nil];
	[fm release];
}

- (void)cleanUpAndShutDown
{
	NSFileManager *fm = [NSFileManager defaultManager];
	//fix screen resolution back to original if fullscreen
	if (fullScreenOption)
	{
		NSLog(@"Changing the resolution back to %@...",currentResolution);
		[self setResolution:currentResolution];
	}
	if (!useXQuartz)
	{
		char *tmp;
		kill((pid_t)(strtoimax([wineskinX11PID UTF8String], &tmp, 10)), 9);
		kill((pid_t)(strtoimax([wrapperBundlePID UTF8String], &tmp, 10)), 9);
		[fm removeItemAtPath:@"/tmp/.X11-unix" error:nil];
		[fm removeItemAtPath:[NSString stringWithFormat:@"/tmp/.X%@-lock",[theDisplayNumber substringFromIndex:1]] error:nil];
	}
	else if (fullScreenOption)
	{
		char *tmp;
		kill((pid_t)(strtoimax([xQuartzBundlePID UTF8String], &tmp, 10)), 9);
		kill((pid_t)(strtoimax([xQuartzX11BinPID UTF8String], &tmp, 10)), 9);
		[fm removeItemAtPath:@"/tmp/.X11-unix" error:nil];
		[fm removeItemAtPath:[NSString stringWithFormat:@"/tmp/.X%@-lock",[theDisplayNumber substringFromIndex:1]] error:nil];
	}
	else //using XQuartz but not override->Fullscreen. Change back to Rootless resolution so it won't be stuck in a fullscreen.
	{
		int xRes = [[currentResolution substringToIndex:[currentResolution rangeOfString:@" "].location] intValue];
		int yRes = [[currentResolution substringFromIndex:[currentResolution rangeOfString:@" "].location+1] intValue]-22;//if the resolution is the yMax-22 it should be the Rootless resolution
		currentResolution = [NSString stringWithFormat:@"%d %d",xRes,yRes];
		NSLog(@"Changing the resolution back to %@...",currentResolution);
		[self setResolution:currentResolution];
	}
	//fix user folders back
	if ([[[fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Documents",winePrefix] error:nil] fileType] isEqualToString:@"NSFileTypeSymbolicLink"])
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Documents",winePrefix] error:nil];
	if ([[[fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/Desktop",winePrefix] error:nil] fileType] isEqualToString:@"NSFileTypeSymbolicLink"])
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/Desktop",winePrefix] error:nil];
	if ([[[fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Videos",winePrefix] error:nil] fileType] isEqualToString:@"NSFileTypeSymbolicLink"])
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Videos",winePrefix] error:nil];
	if ([[[fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Music",winePrefix] error:nil] fileType] isEqualToString:@"NSFileTypeSymbolicLink"])
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Music",winePrefix] error:nil];
	if ([[[fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Pictures",winePrefix] error:nil] fileType] isEqualToString:@"NSFileTypeSymbolicLink"])
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/drive_c/users/Wineskin/My Pictures",winePrefix] error:nil];
	//clean up log files
	if (!debugEnabled)
	{
		[fm removeItemAtPath:wineLogFile error:nil];
		[fm removeItemAtPath:x11LogFile error:nil];
		[fm removeItemAtPath:[NSString stringWithFormat:@"%@/Logs/Winetricks.log",winePrefix] error:nil];
	}
    else if (fullScreenOption)
    {
        NSArray *tempArray = [self readFileToStringArray:wineLogFile];
        NSArray *oldDataArray = [self readFileToStringArray:wineTempLogFile];
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[oldDataArray count]];
        [temp addObjectsFromArray:oldDataArray];
        [temp addObjectsFromArray:tempArray];
        [self writeStringArray:temp toFile:wineLogFile];
    }
	//fixes for multi-user use
	NSArray *tmpy3 = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/dosdevices",winePrefix] error:nil];
	for (NSString *item in tmpy3)
		[self systemCommand:[NSString stringWithFormat:@"chmod -h 777 \"%@/dosdevices/%@\"",winePrefix,item]];
	[self systemCommand:[NSString stringWithFormat:@"chmod 666 \"%@/userdef.reg\"",winePrefix]];
	[self systemCommand:[NSString stringWithFormat:@"chmod 666 \"%@/system.reg\"",winePrefix]];
	[self systemCommand:[NSString stringWithFormat:@"chmod 666 \"%@/user.reg\"",winePrefix]];
	[self systemCommand:[NSString stringWithFormat:@"chmod 666 \"%@/Info.plist\"",contentsFold]];
	[self systemCommand:[NSString stringWithFormat:@"chmod -R 777 \"%@/drive_c\"",winePrefix]];
    //get rid of the preference file
    [fm removeItemAtPath:x11PListFile error:nil];
    [fm removeItemAtPath:[NSString stringWithFormat:@"%@.lockfile",x11PListFile] error:nil];
    [fm removeItemAtPath:tmpFolder error:nil];
	[fm release];
}
- (void)ds:(NSString *)input
{
	CFUserNotificationDisplayNotice(0, 0, NULL, NULL, NULL, CFSTR("Contents of String"), (CFStringRef)input, NULL);
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//get argv to pass on to mainRun
	NSMutableArray *temp = [NSMutableArray arrayWithCapacity:10];
	int i;
	for (i=1;i<argc;i++) [temp addObject:[NSString stringWithUTF8String:argv[i]]];
	id WineskinRun;
	WineskinRun=[Wineskin new];
	[WineskinRun mainRun:temp];
	[WineskinRun release];
	[pool release];
	return 0;
}
