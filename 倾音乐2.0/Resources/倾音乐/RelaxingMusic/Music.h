
#import <Foundation/Foundation.h>

@interface Music : NSObject {
    NSString *name;
    NSString *type;
}
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *type;

- (id)initWithName:(NSString *)_name andType:(NSString *)_type;
@end