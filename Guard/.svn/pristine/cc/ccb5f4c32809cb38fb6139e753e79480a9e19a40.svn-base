//=============================================================================
// Copyright © 2008 Point Grey Research, Inc. All Rights Reserved.
//
// This software is the confidential and proprietary information of Point
// Grey Research, Inc. ("Confidential Information").  You shall not
// disclose such Confidential Information and shall use it only in
// accordance with the terms of the license agreement you entered into
// with PGR.
//
// PGR MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE
// SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE, OR NON-INFRINGEMENT. PGR SHALL NOT BE LIABLE FOR ANY DAMAGES
// SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
// THIS SOFTWARE OR ITS DERIVATIVES.
//=============================================================================
//=============================================================================
// $Id: FlyCapture2Test.cpp,v 1.19 2010-03-11 22:58:37 soowei Exp $
//=============================================================================

#include "stdafx.h"
#include <iostream>
#include <sstream>
#include <cstdio>
#include "FlyCapture2.h"

#include "+Msg/App.h"
#include "+Msg/Proto.h"
#include "+Msg/Transport.h"
#include "+hidi/pause.h"
#include "+math/math.h"
#include "JSONRead.h"

// protocol
#include "nav/nav.pb.cc"

// configuration
static JSONRead cfg("guard.json");
static std::string ownID = cfg.get<std::string>("ownID");
static const double dtWarped = cfg.get<double>("imgPeriod")/cfg.get<double>("timeWarp");
static const double fpsWarped = cfg.get<double>("timeWarp")/cfg.get<double>("imgPeriod");
using namespace FlyCapture2;
using namespace std;

class OCCamera : virtual public Msg::App, virtual public Msg::Time
{
public:  
  OCCamera(void) :
    Msg::App("OCCamera", INF, INF, cfg.get<double>("maxLength")),
    Msg::Time(this, cfg.get<std::string>("timeSourceID"), cfg.get<double>("timeWarp"))
  {}
  
  void processImage(const unsigned char* data, const unsigned int numRows, const unsigned int numCols, const unsigned int numStrides)
  {
    std::string outbox;
    nav::Img img;
    unsigned char* rgb;
    unsigned int row;
    unsigned int col;
    unsigned int layer;
    unsigned int p;
    
    // if time is set
    if(this->isTimeSet())
    {
      rgb = new unsigned char[numRows*numCols*3];

      // get time stamp and fill in the data structure
      img.set_times(this->getTime());
      img.set_fovr(56.15*math::DEGTORAD);
      img.set_steps(numCols);
      img.set_strides(numRows);
      img.set_layers(3);
      p = 0;
      for(layer = 0; layer<3; ++layer)
      {
        for(row = 0; row<numRows; ++row)
        {
          for(col = 0; col<numCols; ++col)
          {
            rgb[p++] = data[3*col+numStrides*row+layer];
          }
        }
      }

      // copy into data output
      img.set_data(rgb, numRows*numCols*3);

      // free memory
      delete[] rgb;
      // serialize output
      Msg::Proto::pack("nav.Img", ownID, img.SerializeAsString(), outbox);
      
      // send output
      this->send(outbox);
    }
    return;
  }
};

static void OCCameraWrapper(const unsigned char* data, const unsigned int numRows, const unsigned int numCols, const unsigned int numStrides, const std::string suburi, const std::string puburi)
{
  // variables that will created during the first function call
  static Msg::Transport transport(suburi, puburi, cfg.get<double>("maxLength"));
  static OCCamera app;
  static bool init = false;
  
  // temporary variables
  size_t k;
  std::vector< std::string > msgTopics;
  std::string message;
  
  // set subscriptions during the first function call
  if(!init)
  {
    app.msgTopics(msgTopics);
    for(k = 0; k<msgTopics.size(); ++k)
    {
      transport.subscribe(msgTopics[k]);
    }
    init = true;
  }
  
  // receive and process all time stamp messages
  transport.receive(message);
  while(!message.empty())
  {
    app.msgProcess(message);
    transport.receive(message);
  }
  
  // process measurements
  app.processImage(data, numRows, numCols, numStrides);
  
  // send outgoing messages
  for(k = 0; k<app.msgOutbox.size(); ++k)
  {
    transport.send(app.msgOutbox[k]);
  }
      
  // clear the outbox
  app.msgClear();
  return;
}

void PrintBuildInfo()
{
	FC2Version fc2Version;
	Utilities::GetLibraryVersion( &fc2Version );

	ostringstream version;
	version << "FlyCapture2 library version: " << fc2Version.major << "." << fc2Version.minor << "." << fc2Version.type << "." << fc2Version.build;
	cout << version.str() << endl;

	ostringstream timeStamp;
	timeStamp <<"Application build date: " << __DATE__ << " " << __TIME__;
	cout << timeStamp.str() << endl << endl;
}

void PrintCameraInfo( CameraInfo* pCamInfo )
{
	cout << endl;
	cout << "*** CAMERA INFORMATION ***" << endl;
	cout << "Serial number -" << pCamInfo->serialNumber << endl;
	cout << "Camera model - " << pCamInfo->modelName << endl;
	cout << "Camera vendor - " << pCamInfo->vendorName << endl;
	cout << "Sensor - " << pCamInfo->sensorInfo << endl;
	cout << "Resolution - " << pCamInfo->sensorResolution << endl;
	cout << "Firmware version - " << pCamInfo->firmwareVersion << endl;
	cout << "Firmware build time - " << pCamInfo->firmwareBuildTime << endl << endl;

}

void PrintFormat7Capabilities( Format7Info fmt7Info )
{
	cout << "Max image pixels: (" << fmt7Info.maxWidth << ", " << fmt7Info.maxHeight << ")" << endl;
	cout << "Image Unit size: (" << fmt7Info.imageHStepSize << ", " << fmt7Info.imageVStepSize << ")" << endl;
	cout << "Offset Unit size: (" << fmt7Info.offsetHStepSize << ", " << fmt7Info.offsetVStepSize << ")" << endl;
	cout << "Pixel format bitfield: 0x" << fmt7Info.pixelFormatBitField << endl;

}

void PrintError( Error error )
{
	error.PrintErrorTrace();
}



int main(int argc, char* argv[])
{
    if(argc<3)
    {
    printf("usage: OC/OCCamera subURI pubURI\n");
    return EXIT_FAILURE;
    }
    
    
	PrintBuildInfo();

	const Mode k_fmt7Mode = MODE_0;
	const PixelFormat k_fmt7PixFmt = PIXEL_FORMAT_RAW8;

	Error error;

	// Since this application saves images in the current folder
	// we must ensure that we have permission to write to this folder.
	// If we do not have permission, fail right away.
	FILE* tempFile = fopen("test.txt", "w+");
	if (tempFile == NULL)
	{
		cout << "Failed to create file in current folder.  Please check permissions." << endl;
		return -1;
	}
	fclose(tempFile);
	remove("test.txt");

	BusManager busMgr;
	unsigned int numCameras;
	error = busMgr.GetNumOfCameras(&numCameras);
	if (error != PGRERROR_OK)
	{
		PrintError( error );
		return -1;
	}


		PGRGuid guid;
		error = busMgr.GetCameraFromIndex(0, &guid);
		if (error != PGRERROR_OK)
		{
			PrintError( error );
			return -1;
		}

	Camera cam;

	// Connect to a camera
	error = cam.Connect(&guid);
	if (error != PGRERROR_OK)
	{
		PrintError( error );
		return -1;
	}

	// Get the camera information
	CameraInfo camInfo;
	error = cam.GetCameraInfo(&camInfo);
	if (error != PGRERROR_OK)
	{
		PrintError( error );
		return -1;
	}
	PrintCameraInfo(&camInfo);

// Query for available Format 7 modes
	Format7Info fmt7Info;
	bool supported;
	fmt7Info.mode = k_fmt7Mode;
	error = cam.GetFormat7Info( &fmt7Info, &supported );
	if (error != PGRERROR_OK)
	{
		PrintError( error );
		return -1;
	}

	PrintFormat7Capabilities( fmt7Info );

	if ( (k_fmt7PixFmt & fmt7Info.pixelFormatBitField) == 0 )
	{
		// Pixel format not supported!
		cout << "Pixel format is not supported" << endl;
		return -1;
	}

	Format7ImageSettings fmt7ImageSettings;
	fmt7ImageSettings.mode = k_fmt7Mode;
	fmt7ImageSettings.offsetX = 0;
	fmt7ImageSettings.offsetY = 0;
	fmt7ImageSettings.width = fmt7Info.maxWidth;
	fmt7ImageSettings.height = fmt7Info.maxHeight;
	fmt7ImageSettings.pixelFormat = k_fmt7PixFmt;

	bool valid;
	Format7PacketInfo fmt7PacketInfo;

	// Validate the settings to make sure that they are valid
	error = cam.ValidateFormat7Settings(
			&fmt7ImageSettings,
			&valid,
			&fmt7PacketInfo );
	if (error != PGRERROR_OK)
	{
		PrintError( error );
		return -1;
	}

	if ( !valid )
	{
		// Settings are not valid
		cout << "Format7 settings are not valid" << endl;
		return -1;
	}

	// Set the settings to the camera
	error = cam.SetFormat7Configuration(
			&fmt7ImageSettings,
			fmt7PacketInfo.recommendedBytesPerPacket );
	Property frmRate;
	frmRate.type = FRAME_RATE;
	frmRate.autoManualMode = false;
	frmRate.onOff = true;
	frmRate.absControl = true;
	frmRate.absValue = fpsWarped;
	error = cam.SetProperty( &frmRate );
	
	if (error != PGRERROR_OK)
	{
		PrintError( error );
		return -1;
	}

	// Start capturing images
	error = cam.StartCapture();
	if (error != PGRERROR_OK)
	{
		PrintError( error );
		return -1;
	}


	Image rawImage;
	unsigned char* rgbData;
	unsigned int numRows;
	unsigned int numCols;
	unsigned int numStrides;

	for ( int imageCnt=0; ; imageCnt++ )
	{
		// Retrieve an image
		error = cam.RetrieveBuffer( &rawImage );
		if (error != PGRERROR_OK)
		{
			PrintError( error );
			continue;
		}

		cout << "Grabbed image " << imageCnt << endl;

		// Create a converted image
		Image convertedImage;

		// Convert the raw image
		error = rawImage.Convert( PIXEL_FORMAT_RGB, &convertedImage );
		if (error != PGRERROR_OK)
		{
			PrintError( error );
			return -1;
		}

	    rgbData = convertedImage.GetData();
	    numRows = convertedImage.GetRows();
	    numCols = convertedImage.GetCols();
	    numStrides = convertedImage.GetStride();
	    cout<<"numStrides:"<<numStrides<<endl;
            OCCameraWrapper(rgbData, numRows, numCols, numStrides, argv[1], argv[2]);
	}

	// Stop capturing images
	error = cam.StopCapture();
	if (error != PGRERROR_OK)
	{
		PrintError( error );
		return -1;
	}

	// Disconnect the camera
	error = cam.Disconnect();
	if (error != PGRERROR_OK)
	{
		PrintError( error );
		return -1;
	}
	

	cout << "Done! Press Enter to exit..." << endl;
	cin.ignore();

	return 0;
}





