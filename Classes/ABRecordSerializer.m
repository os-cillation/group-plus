/*
 
 File: ABRecordSerializer.m
 Abstract: Creates a serializable representation of ABRecordRef
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This ArcTouch software is supplied to you by 
 ArcTouch Inc. ("ArcTouch") in consideration of your agreement to the 
 following terms, and your use, installation, modification or redistribution 
 of this ArcTouch software constitutes acceptance of these terms.  
 If you do not agree with these terms, please do not use, install, 
 modify or redistribute this ArcTouch software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, ArcTouch grants you a personal, non-exclusive
 license, under ArcTouch's copyrights in this original ArcTouch software (the
 "ArcTouch Software"), to use, reproduce, modify and redistribute the ArcTouch
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the ArcTouch Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the ArcTouch Software.
 Neither the name, trademarks, service marks or logos of ArcTouch Inc. may
 be used to endorse or promote products derived from the ArcTouch Software
 without specific prior written permission from ArcTouch.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by ArcTouch herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the ArcTouch Software may be incorporated.
 
 The ArcTouch Software is provided by ArcTouch on an "AS IS" basis.  ARCTOUCH
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE ARCTOUCH SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL ARCTOUCH BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE ARCTOUCH SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF ARCTOUCH HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 ArcTouch Inc. All Rights Reserved.
 */

#import "ABRecordSerializer.h"

#define PHOTO_PROPERTY 99999

@implementation ABRecordSerializer

+ (NSData *)personToData:(ABRecordRef)person {
	NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:5];
	
	// Copies each ABRecordRef property to a NSMutableDictionary
	[self copyProperty:kABPersonFirstNameProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonLastNameProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonMiddleNameProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonPrefixProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonSuffixProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonNicknameProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonFirstNamePhoneticProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonLastNamePhoneticProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonMiddleNamePhoneticProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonOrganizationProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonJobTitleProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonDepartmentProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonBirthdayProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonNoteProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonEmailProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonAddressProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonDateProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonKindProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonPhoneProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonInstantMessageProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonURLProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonRelatedNamesProperty ofPerson:person toDictionary:properties];
	
	// Check if person has an image associated and add it to the dictionary with a pre-defined key
	if (ABPersonHasImageData(person)) {
		CFDataRef imgData = ABPersonCopyImageData(person);
		[properties setObject:(NSData*)imgData forKey:[NSNumber numberWithInt:PHOTO_PROPERTY]];
		CFRelease(imgData);
	}
	
	// Uses archiver to serialize the NSMutableDictionary in a binary format
	return [NSKeyedArchiver archivedDataWithRootObject:properties];
}

+ (ABRecordRef)createPersonFromData:(NSData *)data {
	ABRecordRef person = NULL;
	
	// Deserializes the data to a NSDictionary
	NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	if (dictionary) {
		// Creates a new ABRecordRef to be populated
		person = ABPersonCreate();
		CFErrorRef error = NULL;
		
		// Iterates over the dictionary keys and add them with the corresponding value to the new person (ABRecordRef)
		NSArray *keys = [dictionary allKeys];
		for (NSUInteger i = 0; i < [keys count]; i++) {
			NSNumber *key = [keys objectAtIndex:i];
			id value = [dictionary objectForKey:key];
			ABPropertyID prop = [key intValue];
			
			if (prop == PHOTO_PROPERTY) {
				ABPersonSetImageData(person, (CFDataRef)value, &error);
			} else {
				ABPropertyType type = ABPersonGetTypeOfProperty(prop);
				if (type == kABStringPropertyType) {
					ABRecordSetValue(person, prop, value, &error);
				} else if (type == kABIntegerPropertyType) {
					ABRecordSetValue(person, prop, value, &error);
				} else if (type == kABDateTimePropertyType) {
					ABRecordSetValue(person, prop, value, &error);
				} else if (type == kABMultiStringPropertyType 
						   || type == kABMultiDictionaryPropertyType
						   || type == kABMultiDateTimePropertyType) {
					ABMutableMultiValueRef multiValueProp = [self multiValuePropertyFromDictionary:(NSDictionary*)value];
					if (multiValueProp != NULL) {
						ABRecordSetValue(person, prop, multiValueProp, &error);
						CFRelease(multiValueProp);
					}
				}
			}
			
			if (error != NULL) {
				CFStringRef errorDescription = CFErrorCopyDescription(error);
				NSLog(@"ABRecordSerializer error: %@", errorDescription);
				CFRelease(errorDescription);
				CFRelease(error);
				CFRelease(person);
				return NULL;
			}
		}
	} else {
		NSLog(@"ABRecordSerializer: Couldn't load NSDictionary from NSData.");
	}
	
	return person;
}

+ (ABMutableMultiValueRef)multiValuePropertyFromDictionary:(NSDictionary*)dictionary {
	ABMutableMultiValueRef multiValueProp;
	CFTypeID type = CFGetTypeID([[dictionary allValues] objectAtIndex:0]);
	
	// Transforms a NSDictionary to a ABMutableMultiValueRef
	if (type == CFStringGetTypeID()) {
		multiValueProp = ABMultiValueCreateMutable(kABStringPropertyType);
	} else if (type == CFDateGetTypeID()) {
		multiValueProp = ABMultiValueCreateMutable(kABDateTimePropertyType);
	} else if (type == CFDictionaryGetTypeID()) {
		multiValueProp = ABMultiValueCreateMutable(kABDictionaryPropertyType);
	}
	
	NSArray *keys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(localizedCompare:)];
	for (CFIndex i = 0; i < [keys count]; i++) {
		NSString *key = [keys objectAtIndex:i];
		ABMultiValueAddValueAndLabel(multiValueProp, [dictionary objectForKey:key], (CFStringRef)[key substringFromIndex:3], NULL);
	}
	
	return multiValueProp;
}

+ (NSDictionary*)dictionaryFromMultiValueProperty:(ABMutableMultiValueRef)prop {
	NSMutableDictionary *dictionary = nil;
	CFTypeRef label, value;
	NSString *orderedLabel;
	CFTypeID type;
	
	// Transforms multivalue properties in a NSMutableDictionary to be serialized
	if (ABMultiValueGetCount(prop) > 0) {
		dictionary = [NSMutableDictionary dictionaryWithCapacity:5];
		for (CFIndex i = 0; i < ABMultiValueGetCount(prop); i++) {
			label = ABMultiValueCopyLabelAtIndex(prop, i);
			if (label == NULL)
				label = @"";
			
			orderedLabel = [NSString stringWithFormat:@"%.3d%@", i, label];
			value = ABMultiValueCopyValueAtIndex(prop, i);
			
			if (value != NULL) {
				type = CFGetTypeID(value);
				if (type == CFStringGetTypeID()) {
					[dictionary setObject:(NSString*)value forKey:orderedLabel];
				} else if (type == CFDateGetTypeID()) {
					[dictionary setObject:(NSDate*)value forKey:orderedLabel];
				} else if (type == CFDictionaryGetTypeID()) {
					[dictionary setObject:(NSDictionary*)value forKey:orderedLabel];
				}
				
				CFRelease(value);
			}
			
			CFRelease(label);
		}
	}
	
	return dictionary;
}

+ (void)copyProperty:(ABPropertyID)prop ofPerson:(ABRecordRef)person toDictionary:(NSMutableDictionary*)dict {
	CFTypeRef value = ABRecordCopyValue(person, prop);
	ABPropertyID type;
	
	// Copies the specified property to the NSMutableDictionary considering it's specific type
	if (value != NULL) {
		type = ABPersonGetTypeOfProperty(prop);
		if (type == kABStringPropertyType) {
			[dict setObject:(NSString*)value forKey:[NSNumber numberWithInt:prop]];
		} else if (type == kABIntegerPropertyType) {
			[dict setObject:(NSNumber*)value forKey:[NSNumber numberWithInt:prop]];
		} else if (type == kABDateTimePropertyType) {
			[dict setObject:(NSDate*)value forKey:[NSNumber numberWithInt:prop]];
		} else if (type == kABMultiStringPropertyType 
				   || type == kABMultiDictionaryPropertyType 
				   || type == kABMultiDateTimePropertyType) {
			NSDictionary *propDictionary = [self dictionaryFromMultiValueProperty:value];
			if (propDictionary)
				[dict setObject:propDictionary forKey:[NSNumber numberWithInt:prop]];
		}
		
		CFRelease(value);
	}
}

@end
