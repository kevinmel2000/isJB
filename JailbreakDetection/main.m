//
//  main.m
//  JailbreakDetection
//
//  Created by Augusta Bogie on 2/13/16.
//  Copyright © 2016 Augusta Bogie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>
#include <stdlib.h>

static int is_debugger_present(void)
{
    int name[4];
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    
    info.kp_proc.p_flag = 0;
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    
    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
        perror("sysctl");
        exit(-1);
    }
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}


int main(int argc, char * argv[]) {
    if (is_debugger_present())
    {
        printf("Try to attach to me!");
        return -1;
    }else{
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
