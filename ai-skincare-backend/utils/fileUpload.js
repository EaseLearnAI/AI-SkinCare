const { supabase, bucketName } = require('../config/supabase');
const sharp = require('sharp');
const { v4: uuidv4 } = require('uuid');

/**
 * Upload an image file to Supabase storage
 * 
 * @param {Buffer} fileBuffer - The file buffer
 * @param {string} folder - Folder path within the bucket
 * @param {string} fileName - Optional custom file name
 * @returns {Promise<{url: string, thumbnail: string|null}>} - Object containing URLs
 */
const uploadImage = async (fileBuffer, folder, fileName = null) => {
  try {
    // Generate a unique file name if not provided
    const uniqueFileName = fileName || `${uuidv4()}.jpg`;
    const filePath = `${folder}/${uniqueFileName}`;
    
    // Upload the original image
    const { data: fileData, error: fileError } = await supabase.storage
      .from(bucketName)
      .upload(filePath, fileBuffer, {
        contentType: 'image/jpeg',
        upsert: true
      });
    
    if (fileError) {
      console.error('Error uploading file:', fileError);
      throw new Error(`File upload failed: ${fileError.message}`);
    }
    
    // Create thumbnail (200x200 px)
    const thumbnailBuffer = await sharp(fileBuffer)
      .resize(200, 200, { fit: 'cover' })
      .jpeg({ quality: 80 })
      .toBuffer();
    
    // Upload thumbnail
    const thumbnailPath = `${folder}/thumbnails/${uniqueFileName}`;
    const { data: thumbnailData, error: thumbnailError } = await supabase.storage
      .from(bucketName)
      .upload(thumbnailPath, thumbnailBuffer, {
        contentType: 'image/jpeg',
        upsert: true
      });
    
    if (thumbnailError) {
      console.error('Error uploading thumbnail:', thumbnailError);
      // Continue even if thumbnail fails
    }
    
    // Get public URLs
    const { data: fileUrl } = supabase.storage
      .from(bucketName)
      .getPublicUrl(filePath);
    
    let thumbnailUrl = null;
    if (!thumbnailError) {
      const { data: thumbUrl } = supabase.storage
        .from(bucketName)
        .getPublicUrl(thumbnailPath);
      thumbnailUrl = thumbUrl?.publicUrl;
    }
    
    return {
      url: fileUrl?.publicUrl,
      thumbnail: thumbnailUrl
    };
  } catch (error) {
    console.error('Error in file upload process:', error);
    throw error;
  }
};

/**
 * Delete an image and its thumbnail from storage
 * 
 * @param {string} fileUrl - The full URL of the file to delete
 * @returns {Promise<boolean>} - Success status
 */
const deleteImage = async (fileUrl) => {
  try {
    // Extract the file path from the URL
    const url = new URL(fileUrl);
    const pathParts = url.pathname.split('/');
    
    // The path should start after the bucket name
    const bucketIndex = pathParts.findIndex(part => part === bucketName);
    if (bucketIndex === -1) {
      throw new Error('Invalid file URL');
    }
    
    const filePath = pathParts.slice(bucketIndex + 1).join('/');
    
    // Delete the file
    const { error: fileError } = await supabase.storage
      .from(bucketName)
      .remove([filePath]);
    
    if (fileError) {
      console.error('Error deleting file:', fileError);
      return false;
    }
    
    // Try to delete thumbnail if it exists
    const folderPath = filePath.split('/').slice(0, -1).join('/');
    const fileName = filePath.split('/').pop();
    const thumbnailPath = `${folderPath}/thumbnails/${fileName}`;
    
    await supabase.storage
      .from(bucketName)
      .remove([thumbnailPath]);
    
    return true;
  } catch (error) {
    console.error('Error in file deletion process:', error);
    return false;
  }
};

module.exports = {
  uploadImage,
  deleteImage
}; 