# How to Use APIs for NFTs

## Mintgarden

### Get a Collection

Get URL like this

```text
https://api.mintgarden.io/collections/col16fpva26fhdjp2echs3cr7c30gzl7qe67hu9grtsjcqldz354asjsyzp6wx/nfts?size=100
```

You get JSON with Paging

```json
{
    "items": ["(allItems)"],
    "page": null,
    "size": 100,
    "next": ">i:2408296~s:fc26a9f5d21b1c8b4c3f6802c7a463777b6917bc234b50411b6aae96709661c6",
    "previous": "<i:2410949~s:05947e2201c1584305a7cecb5a15ec61621140057fa0361f822e934f26fef5c2"
}
```

When you want to get the next Page get this URL

```text
https://api.mintgarden.io/collections/col16fpva26fhdjp2echs3cr7c30gzl7qe67hu9grtsjcqldz354asjsyzp6wx/nfts?size=100&page=%3Ei:2408296~s:fc26a9f5d21b1c8b4c3f6802c7a463777b6917bc234b50411b6aae96709661c6
```

### Get a single NFT

Get URL like this.

Query Method is **a lot slower** then method with collections from above. It seems like query does a table scan without index while when you know the correct method an query for specific id (collection in upper example) it is a LOT faster. Seems like you then have an efficient database query. So what i need for single NFT is how to query mintgarden for specific NFT ID.

```text
https://api.mintgarden.io/search?query=nft1pxpkjapa3fcukccrsylajyq43mg0ezu3v0p0l404340jq7737uhqp7wl8y
```

You get JSON answer like this

```json
{
    "collections": [],
    "nfts": [
        {
            "id": "098369743d8a71cb6303813fd910158ed0fc8b9163c2ffd5f58d5f207bd1f72e",
            "encoded_id": "nft1pxpkjapa3fcukccrsylajyq43mg0ezu3v0p0l404340jq7737uhqp7wl8y"
        }
    ],
    "profiles": []
}
```