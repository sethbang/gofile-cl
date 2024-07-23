# Gofile API Documentation

Gofile is a file storage system that operates using accounts, files, and folders. This README provides detailed information about the Gofile API endpoints and their usage.

## Table of Contents
1. [Authentication](#authentication)
2. [Basic Concepts](#basic-concepts)
3. [API Endpoints](#api-endpoints)
   - [Get Server List](#get-server-list)
   - [Upload File](#upload-file)
   - [Create Folder](#create-folder)
   - [Modify Content Attribute](#modify-content-attribute)
   - [Delete Contents](#delete-contents)
   - [Delete Single Content](#delete-single-content)
   - [Get Content Information](#get-content-information)
   - [Search Content](#search-content)
   - [Create Direct Link](#create-direct-link)
   - [Update Direct Link](#update-direct-link)
   - [Delete Direct Link](#delete-direct-link)
   - [Copy Contents](#copy-contents)
   - [Copy Single Content](#copy-single-content)
   - [Move Contents](#move-contents)
   - [Move Single Content](#move-single-content)
   - [Get Account ID](#get-account-id)
   - [Get Account Details](#get-account-details)
   - [Reset Authentication Token](#reset-authentication-token)

## Authentication

All endpoints requiring authentication must be authenticated via your API token. You can find your token in your profile page. The token can be sent either in the headers of your request via `Authorization: Bearer your_token`, or directly as a parameter.

## Basic Concepts

- An account always has a root folder that cannot be deleted.
- If you upload a file without specifying any parameters, a guest account and a root folder will be created. The file will be uploaded to a new folder within the root folder.
- To upload multiple files, first upload the initial file, then obtain the `folderId` from the response of the request. You can then upload the remaining files one at a time, specifying the `folderId` as a parameter.

## API Endpoints

### Get Server List

Returns a list of servers available to receive content.

**Endpoint:** `GET https://api.gofile.io/servers`

**Parameters:**
- `zone` (optional): Specifies a zone (eu for Europe, or na for North America).

**Note:** Do not call this function more than once every 10 seconds.

### Upload File

Upload a file to a server.

**Endpoint:** `POST https://store1.gofile.io/contents/uploadfile`

**Parameters:**
- `file` (required): The file to be uploaded.
- `token` (optional): Your account API token.
- `folderId` (optional): The identifier of the folder where the file will be stored.

### Create Folder

Create a new folder in the specified parent folder.

**Endpoint:** `POST https://api.gofile.io/contents/createFolder`

**Parameters:**
- `token` (required): Your account API token.
- `parentFolderId` (required): The id of the parent folder.
- `folderName` (optional): The name of the new folder.

### Modify Content Attribute

Modify a specific content attribute.

**Endpoint:** `PUT https://api.gofile.io/contents/{contentId}/update`

**Parameters:**
- `token` (required): Your account API token.
- `attribute` (required): The attribute to modify (name, description, tags, public, expiry, password).
- `attributeValue` (required): The value of the attribute to define.

### Delete Contents

Deletes content specified by their ids (files and folders).

**Endpoint:** `DELETE https://api.gofile.io/contents`

**Parameters:**
- `token` (required): Your account API token.
- `contentsId` (required): A comma-separated list of the IDs of the files or folders to be deleted.

### Delete Single Content

Delete a single content.

**Endpoint:** `DELETE https://api.gofile.io/contents/{contentId}`

**Parameters:**
- `token` (required): Your account API token.

### Get Content Information

Get information about a content (must be a folder).

**Endpoint:** `GET https://api.gofile.io/contents/{contentId}`

**Parameters:**
- `token` (required): Your account API token.
- `cache` (optional): A boolean indicating if the cache should be used.
- `password` (optional): The hashed password (sha256) for accessing the content if it is password protected.

### Search Content

Search for content within a specific folder based on a search string.

**Endpoint:** `GET https://api.gofile.io/contents/search`

**Parameters:**
- `token` (required): Your account API token.
- `contentId` (required): ID of the folder to search into.
- `searchedString` (required): String to search for.

### Create Direct Link

Create a direct link to content (file or folder).

**Endpoint:** `POST https://api.gofile.io/contents/{contentId}/directlinks`

**Parameters:**
- `token` (required): Your account API token.
- `expireTime` (optional): The expiration time of the direct link.
- `sourceIpsAllowed` (optional): An array of source IPs allowed to access the direct link.
- `domainsAllowed` (optional): An array of domains allowed to access the direct link.
- `auth` (optional): An array of user:pass authentication required to access the direct link.

### Update Direct Link

Updates an existing direct link with new parameters.

**Endpoint:** `PUT https://api.gofile.io/contents/{contentId}/directlinks/{directLinkId}`

**Parameters:**
- `token` (required): Your account API token.
- Other parameters are the same as in Create Direct Link.

### Delete Direct Link

Delete a direct link.

**Endpoint:** `DELETE https://api.gofile.io/contents/{contentId}/directlinks/{directLinkId}`

**Parameters:**
- `token` (required): Your account API token.

### Copy Contents

Copy a list of contents (files or folders) to a specific folder.

**Endpoint:** `POST https://api.gofile.io/contents/copy`

**Parameters:**
- `token` (required): Your account API token.
- `contentsId` (required): The comma-separated list of contentId to be copied.
- `folderId` (required): The id of the destination folder.

### Copy Single Content

Copy a single content to a specific folder.

**Endpoint:** `POST https://api.gofile.io/contents/{contentId}/copy`

**Parameters:**
- `token` (required): Your account API token.
- `folderId` (required): The id of the destination folder.

### Move Contents

Move a list of contents (files or folders) to a specific folder.

**Endpoint:** `PUT https://api.gofile.io/contents/move`

**Parameters:**
- `token` (required): Your account API token.
- `contentsId` (required): The comma-separated list of contentId to be moved.
- `folderId` (required): The id of the destination folder.

### Move Single Content

Move a single content to a specific folder.

**Endpoint:** `PUT https://api.gofile.io/contents/{contentId}/move`

**Parameters:**
- `token` (required): Your account API token.
- `folderId` (required): The id of the destination folder.

### Get Account ID

Get account Id.

**Endpoint:** `GET https://api.gofile.io/accounts/getid`

**Parameters:**
- `token` (required): Your account API token.

### Get Account Details

Retrieve account details.

**Endpoint:** `GET https://api.gofile.io/accounts/{accountId}`

**Parameters:**
- `token` (required): Your account API token.

### Reset Authentication Token

Resets your authentication token. A new login link will be sent to your email.

**Endpoint:** `POST https://api.gofile.io/accounts/{accountId}/resettoken`

**Parameters:**
- `token` (required): Your actual account API token.

## Note

Gofile is in BETA, and the endpoints may be modified in the future. If you use this API, please check back regularly to see if any changes have been made. If you notice any mistake or have any inquiries, please feel free to reach out via the contact page.

Last update: 2024-06-12
