package com.hzgc.cloud.peoman.worker.service;

import com.google.common.base.Stopwatch;
import com.hzgc.cloud.peoman.worker.dao.InnerFeatureMapper;
import com.hzgc.cloud.peoman.worker.dao.PictureMapper;
import com.hzgc.cloud.peoman.worker.model.InnerFeature;
import com.hzgc.cloud.peoman.worker.model.Picture;
import com.hzgc.jniface.FaceUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Slf4j
@Component
class LoadDataFromTiDB {
    @Autowired
    private PictureMapper pictureMapper;
    @Autowired
    private InnerFeatureMapper innerFeatureMapper;
    @Autowired
    private MemeoryCache memeoryCache;
    @Autowired
    private PeopleCompare peopleCompare;

    void load(int offset, int limit) {
        Stopwatch stopwatch = new Stopwatch();
        List<Picture> pictureList = pictureMapper.selectByPrimaryKey(offset, limit);
        if (pictureList != null && pictureList.size() > 0) {
            log.info("Load data from databases successfull, offset {}, limit {}, time {}",
                    offset, limit, stopwatch.elapsedMillis());
            for(Picture picture : pictureList) {
                log.info("--------------"+picture.getPeopleId());
            }
            cacheToMemeory(pictureList);
        } else {
            log.error("Load data failed, offset {}, limit {}, time {}", offset, limit, stopwatch.elapsedMillis());
        }

        List<InnerFeature> featureList = innerFeatureMapper.select();
        peopleCompare.putData(featureList);
    }

    private void cacheToMemeory(List<Picture> pictures) {
        List<ComparePicture> comparePictureList = new ArrayList<>();
        for (Picture picture : pictures) {
            if (picture.getBitFeature() != null &&
                    picture.getId() != null &&
                    picture.getPeopleId() != null) {
                ComparePicture comparePicture = new ComparePicture();
                comparePicture.setId(picture.getId());
                comparePicture.setBitFeature(FaceUtil.base64Str2BitFeature(picture.getBitFeature()));
                comparePicture.setPeopleId(picture.getPeopleId());
                comparePicture.setFlagId(picture.getFlagId());
                comparePicture.setName(picture.getName());
                comparePictureList.add(comparePicture);
            }
        }
        memeoryCache.putData(comparePictureList);
    }


}
