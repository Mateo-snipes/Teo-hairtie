-- Add this entry inside ox_inventory/data/items.lua

['scrunchie'] = {
    label = 'Scrunchie',
    weight = 50,
    stack = false,
    close = true,
    consume = 0,
    description = 'A hair scrunchie used to tie your hair up or let it back down.',
    client = {
        export = 'Teo-hairtoggle.useScrunchie'
    }
},
