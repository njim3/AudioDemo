//
//  Conf.h
//  AudioDemo
//
//  Created by njim3 on 01/02/2018.
//  Copyright © 2018 cnbmsmart. All rights reserved.
//

#ifndef Conf_h
#define Conf_h

#define DOCUMENT_PATH                   [NSSearchPathForDirectoriesInDomains(   \
                                            NSDocumentDirectory, NSUserDomainMask, \
                                            YES) objectAtIndex: 0]

#define AUDIO_FOLDER_NAME               @"audios"

#define AUDIO_FOLDER_PATH               [DOCUMENT_PATH stringByAppendingPathComponent:  \
                                            AUDIO_FOLDER_NAME]


#endif /* Conf_h */
