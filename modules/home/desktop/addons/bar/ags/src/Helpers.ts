import GObject from "gi://GObject?version=2.0";

type PlainObject = { [key: string]: any };

export function toPlainObject(thing: any, visited: Map<any, any> = new Map()): any {
    if (thing == null) {
        return thing;
    }

    if (typeof thing != "object" && !Array.isArray(thing)) {
        return thing;
    }

    // Avoid infinite loops due to circular references
    if (visited.get(thing) != undefined) {
        // return { circularReference: true };
        return visited.get(thing);
    }

    if (thing instanceof GObject.Object) {
        const plainObject: PlainObject = {};
        visited.set(thing, plainObject);

        // Get the list of properties using GObject.Object.list_properties
        const properties = GObject.Object.list_properties.call(thing);

        for (const prop of properties) {
            let value: any = "[ERROR]";

            try {
                value = thing[prop.name];

                // If the property value is another GObject.Object, process it recursively
            } catch (e) {
                // Handle errors gracefully
                value = "[unreadable]";
            }

            plainObject[prop.name] = toPlainObject(value, visited);
        }
        return plainObject;
    }

    let plainObject: PlainObject = Array.isArray(thing) ? [] : {}
    visited.set(thing, plainObject);

    Object.keys(thing).forEach((key) => {
        plainObject[key] = toPlainObject(thing[key], visited);
    });

    return plainObject;
}

export function pp(thing: any) {
    thing = toPlainObject(thing);

    const cache = new Set();
    print(
        JSON.stringify(
            thing,
            (_, value) => {
                if (typeof value === "object" && value !== null) {
                    if (cache.has(value)) {
                        // Circular reference found, discard key
                        return "[CIRCULAR REFERANCE]";
                    }
                    // Store value in our collection
                    cache.add(value);
                }
                return value;
            },
            2,
        ),
    );
}
