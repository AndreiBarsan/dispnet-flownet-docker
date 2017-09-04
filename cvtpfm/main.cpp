// Converts a pfm into a png, so we can use the KITTI devkit to evaluate the
// accuracy of the depthmaps created by dispnet.

#include <fstream>
#include <iostream>
#include <string>
#include <limits>
#include "pfmLib/ImageIOpfm.h"

#include <opencv/cv.h>
#include <opencv/highgui.h>

using namespace std;

int main(int argc, char *argv[])
{
  if (argc != 2) {
    cerr << "Usage: " << argv[0] << " <list-of-pfms.txt>" << endl;
    return 1;
  }

  string fpath = argv[1];
  cout << "Will process files from list: " << fpath << endl;

  ifstream file_list(fpath.c_str(), ifstream::in);
  string pfm_name;
  int count = 0;
  while(getline(file_list, pfm_name)) {
    cout << "PFM to read from: " << pfm_name << endl;

    cv::Mat mat;
    ReadFilePFM(mat, pfm_name, false);
    // 
    // Convert 0-areas to 255-areas. Not idiomatic.
    printf("Size: %d, %d\n", mat.rows, mat.cols);
    for(int i = 0; i < mat.rows; ++i) {
      for(int j = 0; j < mat.cols; ++j) {
        float disp = mat.at<float>(i, j);
        float depth = 707 * 0.53 / disp;
        if (depth > 20.0f) {
          mat.at<float>(i, j) = 255.0f;
        }
        else {
          mat.at<float>(i, j) = depth * 1.5f;
        }
      }
    }

    cv::Mat result;
    mat.convertTo(result, CV_16U, 1000.0f);

    if (++count % 75 == 0) {
      cv::imshow("Scaled result", result);
      cv::waitKey();
    }

    string folder = pfm_name.substr(0, pfm_name.rfind('/') - 1);
    string parent = folder.substr(0, folder.rfind('/'));
    string fname = pfm_name.substr(pfm_name.rfind('/') + 1);
    string fname_no_ext = fname.substr(0, fname.rfind('.'));

    //cout << "Fname: " << fname << endl;
    //cout << "Fname no ext: " << fname_no_ext << endl;
    //cout << "Folder: " << folder << endl;
    //cout << "Parent: " << parent << endl;

    string result_fpath = parent + "/" + "disp_0" + "/" + fname_no_ext + ".png";
    cout << result_fpath << endl;

    imwrite(result_fpath, result);
  }

  cout << "Finished processing " << count << " pfms." << endl;

  return 0;
}
