import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PageManager {
  int currentPage = 0;

  PageManager(this._pageController);

  PageController _pageController;

  void setPage(page) {
    if (page == currentPage) return;
    currentPage = page;
    this._pageController.jumpToPage(page);
  }

}
