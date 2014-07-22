

#import "Music.h"

@implementation Music
@synthesize name, type;

- (id)initWithName:(NSString *)_name andType:(NSString *)_type {
    if (self = [super init]) {
        self.name = _name;
        self.type = _type;
    }
    return self;
}

@end
